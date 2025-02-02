//
//  FloatingSearchBar.swift
//  DealifyApp
//
//  Created by Hubert Khouzam on 2025-02-01.
//

import Foundation
import SwiftUI
import MapboxMaps

// MARK: - FloatingSearchBar

struct FloatingSearchBar: View {
    @Binding var searchText: String
    var onSearch: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)
            
            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text("Search for groceries...")
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.leading, 4)
                }
                TextField("", text: $searchText, onCommit: onSearch)
                    .foregroundColor(.white)
                    .tint(.white)
            }
        }
        .padding()
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(radius: 5)
        .padding(.horizontal)
        .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
        .padding(.top, 0)
        .background(Color.clear)
        .position(x: UIScreen.main.bounds.width / 2, y: 120)
        .zIndex(1)
    }
}
