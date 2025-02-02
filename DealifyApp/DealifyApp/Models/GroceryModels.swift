//
//  GroceryModels.swift
//  DealifyApp
//
//  Created by Hubert Khouzam on 2025-02-01.
//

import Foundation

// MARK: - GroceryItem

struct GroceryItem: Codable, Identifiable {
    let text: String // Corresponds to the "text" key in JSON
    let price: String // Corresponds to the "price" key in JSON
    let rank: Int
    let store: String // Corresponds to the "store" key in JSON
    var id: Int {rank}
}

// MARK: - StoreLocation

struct StoreLocation: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
}

