//
//  JournalStore.swift
//  JournalApp
//
//  Created by Kristina Yaroshenko on 23.04.2025.
//

import Foundation
import UIKit

class JournalStore: ObservableObject {
    @Published var entries: [JournalEntry] = []
    
    private let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedEntries")
    
    init() {
        loadEntries()
    }
    
    func loadEntries() {
        do {
            let data = try Data(contentsOf: savePath)
            entries = try JSONDecoder().decode([JournalEntry].self, from: data)
        } catch {
            entries = []
        }
    }
    
    func saveEntries() {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: savePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("Unable to save data")
        }
    }
    
    func saveImage(_ image: UIImage, forEntry entry: JournalEntry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[index].imageData = image.jpegData(compressionQuality: 0.8)
        saveEntries()
    }

    func loadImage(forEntry entry: JournalEntry) -> UIImage? {
        guard let data = entry.imageData else { return nil }
        return UIImage(data: data)
    }
}

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
