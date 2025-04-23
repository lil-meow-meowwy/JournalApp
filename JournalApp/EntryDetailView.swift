//
//  EntryDetailView.swift
//  JournalApp
//
//  Created by Kristina Yaroshenko on 23.04.2025.
//

import SwiftUICore
import SwiftUI

struct EntryDetailView: View {
    @ObservedObject var journalStore: JournalStore
    @State private var isEditing = false
    @State private var editableEntry: JournalEntry
    
    init(journalStore: JournalStore, entry: JournalEntry) {
        self.journalStore = journalStore
        self._editableEntry = State(initialValue: entry)
    }
    
    var body: some View {
        Group {
            if isEditing {
                EditEntryView(journalStore: journalStore, entry: $editableEntry, isEditing: $isEditing)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text(editableEntry.title)
                                .font(.largeTitle)
                            Spacer()
                            if let mood = editableEntry.mood {
                                Text(mood.emoji)
                                    .font(.largeTitle)
                            }
                        }
                        
                        Text(editableEntry.date.formatted(date: .long, time: .shortened))
                            .foregroundColor(.gray)
                        
                        if let image = journalStore.loadImage(forEntry: editableEntry) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(8)
                        }
                        
                        Text(editableEntry.content)
                            .font(.body)
                        
                        if !editableEntry.tags.isEmpty {
                            TagList(tags: editableEntry.tags)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Entry")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        // Update the original entry
                        if let index = journalStore.entries.firstIndex(where: { $0.id == editableEntry.id }) {
                            journalStore.entries[index] = editableEntry
                            journalStore.saveEntries()
                        }
                    }
                    isEditing.toggle()
                }
            }
        }
    }
}
