//
//  TagView.swift
//  JournalApp
//
//  Created by Kristina Yaroshenko on 23.04.2025.
//

import SwiftUICore
import SwiftUI

struct TagView: View {
    @Binding var tags: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Tags")
                .font(.headline)
            TagEditor(tags: $tags)
        }
    }
}

struct TagEditor: View {
    @Binding var tags: [String]
    @State private var newTag = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Add tag", text: $newTag, onCommit: addTag)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .onTapGesture {
                                if let index = tags.firstIndex(of: tag) {
                                    tags.remove(at: index)
                                }
                            }
                    }
                }
            }
        }
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespaces)
        guard !trimmedTag.isEmpty, !tags.contains(trimmedTag) else {
            newTag = ""
            return
        }
        tags.append(trimmedTag)
        newTag = ""
    }
}
