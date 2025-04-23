//
//  AddEntryView.swift
//  JournalApp
//
//  Created by Kristina Yaroshenko on 23.04.2025.
//

import SwiftUICore
import UIKit
import SwiftUI

struct AddEntryView: View {
    @ObservedObject var journalStore: JournalStore
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var mood: JournalEntry.MoodRating?
    @State private var tags: [String] = []
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter title", text: $title)
                }
                
                Section(header: Text("Content")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                }
                
                Section(header: Text("Mood")) {
                    Picker("How are you feeling?", selection: $mood) {
                        Text("None").tag(Optional<JournalEntry.MoodRating>.none)
                        ForEach(JournalEntry.MoodRating.allCases, id: \.self) { mood in
                            Text("\(mood.emoji) \(String(describing: mood).capitalized)").tag(Optional(mood))
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                Section(header: Text("Tags")) {
                    TagView(tags: $tags)
                }
                
                Section(header: Text("Photo")) {
                    Button("Add Photo") {
                        showingImagePicker = true
                    }
                }
            }
            .navigationTitle("New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newEntry = JournalEntry(
                            title: title,
                            content: content,
                            date: Date(),
                            mood: mood,
                            tags: tags,
                            imageData: nil
                        )
                        
                        if let inputImage = inputImage {
                            journalStore.saveImage(inputImage, forEntry: newEntry)
                        }
                        
                        journalStore.entries.append(newEntry)
                        journalStore.saveEntries()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: $inputImage)
            }
        }
    }
    
    func loadImage() {
        // Image will be saved when the entry is created
    }
}
