//
//  BookmarkModels.swift
//  DealifyApp
//
//  Created by Nathan Audegond on 02/02/2025.
//

// MARK: - BookmarkItem

import Foundation
import Combine

struct BookmarkItem: Identifiable, Codable {
    let id: Int
    let name: String
    let price: String
    let store: String
    let dateAdded: Date
    
    init(from groceryItem: GroceryItem) {
        self.id = groceryItem.id
        self.name = groceryItem.name
        self.price = groceryItem.price
        self.store = groceryItem.store
        self.dateAdded = Date()
    }
}

// MARK: - BookmarkManager
class BookmarkManager: ObservableObject {
    @Published var bookmarkedItems: [BookmarkItem] = []
    private let saveKey = "bookmarkedItems"
    
    init() {
        loadBookmarks()
    }
    
    func addBookmark(_ item: GroceryItem) {
        let bookmarkItem = BookmarkItem(from: item)
        if !bookmarkedItems.contains(where: { $0.id == bookmarkItem.id }) {
            bookmarkedItems.append(bookmarkItem)
            saveBookmarks()
        }
    }
    
    func removeBookmark(id: Int) {
        bookmarkedItems.removeAll { $0.id == id }
        saveBookmarks()
    }
    
    private func saveBookmarks() {
        if let encoded = try? JSONEncoder().encode(bookmarkedItems) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadBookmarks() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([BookmarkItem].self, from: data) {
            bookmarkedItems = decoded
        }
    }
}
