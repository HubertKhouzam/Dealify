//
//  StoreLocationViewModel.swift
//  DealifyApp
//
//  Created by Hubert Khouzam on 2025-02-01.
//

import Foundation

import SwiftUI
import Combine

class StoreLocationViewModel: ObservableObject {
    @Published var storeLocations: [StoreLocation] = []
    
    func fetchStoreLocations(searchText: String) {
        guard !searchText.isEmpty else { return }
        
        let urlString = "https://dealify-n5sl.onrender.com/items/\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let items = try JSONDecoder().decode([GroceryItem].self, from: data)
                DispatchQueue.main.async {
                    self?.storeLocations = items.compactMap { item in
                        sampleLocations.first { $0.name == item.store }
                    }
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
}
