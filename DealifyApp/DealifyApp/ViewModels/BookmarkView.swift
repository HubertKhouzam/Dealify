//
//  BookmarkView.swift
//  DealifyApp
//
//  Created by Nathan Audegond on 02/02/2025.
//
import Foundation
import Combine
import SwiftUI


struct BookmarkView: View {
    @ObservedObject var bookmarkManager: BookmarkManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(bookmarkManager.bookmarkedItems) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.name)
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
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        bookmarkManager.removeBookmark(id: bookmarkManager.bookmarkedItems[index].id)
                    }
                }
            }
            .navigationTitle("Saved Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
