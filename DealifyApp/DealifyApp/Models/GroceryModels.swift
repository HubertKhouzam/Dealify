//
//  GroceryModels.swift
//  DealifyApp
//
//  Created by Hubert Khouzam on 2025-02-01.
//

import Foundation

// MARK: - GroceryItem

struct GroceryItem: Codable, Identifiable {
    let id: Int
    let name: String
    let brand: String
    let price: String // Price is a string
    let store: String
}

// MARK: - StoreLocation

struct StoreLocation: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
}

