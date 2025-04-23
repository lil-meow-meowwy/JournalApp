//
//  ContentView.swift
//  JournalApp
//
//  Created by Kristina Yaroshenko on 23.04.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var journalStore = JournalStore()
    @State private var showingAddView = false
    @State private var showingSettings = false
    @State private var searchText = ""
    
    // Computed property for filtered entries
    var filteredEntries: [JournalEntry] {
        if searchText.isEmpty {
            return journalStore.entries.sorted { $0.date > $1.date } // Newest first
        } else {
            let searchLowercased = searchText.lowercased()
            return journalStore.entries.filter { entry in
                entry.title.lowercased().contains(searchLowercased) ||
                entry.content.lowercased().contains(searchLowercased) ||
                entry.tags.contains { $0.lowercased().contains(searchLowercased) }
            }
            .sorted { $0.date > $1.date } // Newest first
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                SearchBar(text: $searchText)
                    .padding(.vertical, 8)
                
                ForEach(filteredEntries) { entry in
                    NavigationLink(destination: EntryDetailView(journalStore: journalStore, entry: entry)) {
                        EntryRow(entry: entry)
                    }
                }
                .onDelete(perform: deleteEntry)
            }
            .navigationTitle("My Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddView) {
                AddEntryView(journalStore: journalStore)
            }
            .sheet(isPresented: $showingSettings) {
                NavigationView {
                    SettingsView()
                }
            }
        }
    }
    
    func deleteEntry(at offsets: IndexSet) {
        journalStore.entries.remove(atOffsets: offsets)
        journalStore.saveEntries()
    }
}

struct EntryRow: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(entry.title)
                    .font(.headline)
                Spacer()
                if let mood = entry.mood {
                    Text(mood.emoji)
                }
            }
            
            Text(entry.date, style: .date)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if !entry.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(entry.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search entries...", text: $text)
                .padding(8)
                .padding(.horizontal, 24)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                text = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
        }
        .padding(.horizontal, 8)
    }
}

struct JournalEntry: Identifiable, Codable {
    let id = UUID()
    var title: String
    var content: String
    let date: Date
    var mood: MoodRating?
    var tags: [String]
    var imageData: Data?
    
    enum MoodRating: Int, Codable, CaseIterable {
        case terrible = 1
        case bad = 2
        case okay = 3
        case good = 4
        case great = 5
        
        var emoji: String {
            switch self {
            case .terrible: return "😫"
            case .bad: return "😔"
            case .okay: return "😐"
            case .good: return "🙂"
            case .great: return "😁"
            }
        }
    }
}

struct TagList: View {
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Tags")
                .font(.headline)
            
            FlowLayout(data: tags, spacing: 8) { tag in
                Text(tag)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(15)
            }
        }
    }
}

struct FlowLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content
    
    @State private var totalHeight: CGFloat = 0
    
    init(data: Data, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        var lastHeight = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(Array(data.enumerated()), id: \.element) { index, element in
                content(element)
                    .padding([.trailing, .bottom], spacing)
                    .alignmentGuide(.leading) { dimension in
                        if (abs(width - dimension.width) > geometry.size.width) {
                            width = 0
                            height -= lastHeight
                        }
                        let result = width
                        if index == data.count - 1 {
                            width = 0
                        } else {
                            width -= dimension.width
                        }
                        return result
                    }
                    .alignmentGuide(.top) { dimension in
                        let result = height
                        lastHeight = dimension.height
                        return result
                    }
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

