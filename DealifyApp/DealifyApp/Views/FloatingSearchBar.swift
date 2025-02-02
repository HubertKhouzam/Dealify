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
    @FocusState private var isSearchFocused: Bool
    var onSearch: () -> Void
    
    var body: some View {
        HStack {
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
                        .focused($isSearchFocused)
                }
                
                if !searchText.isEmpty || isSearchFocused {
                    Button(action: {
                        searchText = ""
                        isSearchFocused = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                      to: nil, from: nil, for: nil)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.trailing, 4)
                    }
                }
            }
            .padding()
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 30))
        }
        .padding(.horizontal)
        .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
        .position(x: UIScreen.main.bounds.width / 2, y: 120)
        .zIndex(1)
    }
}
