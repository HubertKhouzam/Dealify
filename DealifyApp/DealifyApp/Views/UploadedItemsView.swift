//
//  UploadedItemsView.swift
//  DealifyApp
//
//  Created by Nathan Audegond on 02/02/2025.
//

import SwiftUI

struct UploadedItemsView: View {
    let uploadedItems: [GroceryItem]
    
    var body: some View {
        NavigationView {
            List(uploadedItems, id: \.id) { item in
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.text)
                        .font(.headline)
                    
                    HStack {
                        Text(item.store)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(item.price)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Uploaded Items")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
