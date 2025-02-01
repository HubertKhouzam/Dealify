import Foundation
import Combine
import SwiftUI

struct BookmarkView: View {
    @ObservedObject var bookmarkManager: BookmarkManager
    @Environment(\.dismiss) private var dismiss
    
    var totalPrice: Double {
        bookmarkManager.bookmarkedItems
            .compactMap { Double($0.price.replacingOccurrences(of: "$", with: "")) }
            .reduce(0, +)
    }
    
    var body: some View {
        NavigationView {
            VStack {
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
                
                // Total Price
                Text("Total: \(totalPrice, specifier: "%.2f")$")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
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
