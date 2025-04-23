//
//  EditEntryView.swift
//  JournalApp
//
//  Created by Kristina Yaroshenko on 23.04.2025.
//

import SwiftUICore
import UIKit
import SwiftUI

struct EditEntryView: View {
    @ObservedObject var journalStore: JournalStore
    @Binding var entry: JournalEntry
    @Binding var isEditing: Bool
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Title", text: $entry.title)
            }
            
            Section(header: Text("Content")) {
                TextEditor(text: $entry.content)
                    .frame(minHeight: 200)
            }
            
            Section(header: Text("Mood")) {
                Picker("How are you feeling?", selection: $entry.mood) {
                    Text("None").tag(Optional<JournalEntry.MoodRating>.none)
                    ForEach(JournalEntry.MoodRating.allCases, id: \.self) { mood in
                        Text("\(mood.emoji) \(String(describing: mood).capitalized)").tag(Optional(mood))
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
            
            Section(header: Text("Tags")) {
                TagView(tags: $entry.tags)
            }
            
            Section(header: Text("Photo")) {
                if let image = journalStore.loadImage(forEntry: entry) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(8)
                    
                    Button("Remove Photo") {
                        entry.imageData = nil
                        journalStore.saveEntries()
                    }
                    .foregroundColor(.red)
                }
                
                Button("Add Photo") {
                    showingImagePicker = true
                }
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        journalStore.saveImage(inputImage, forEntry: entry)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
