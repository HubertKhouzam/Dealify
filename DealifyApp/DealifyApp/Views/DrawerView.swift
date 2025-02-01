import Foundation
import SwiftUI
import MapboxMaps

struct DrawerView: View {
    @Binding var drawerHeight: CGFloat
    @Binding var isExpanded: Bool
    @Binding var mapView: MapView?
    @Binding var storeLocations: [StoreLocation]
    @ObservedObject var viewModel: StoreLocationViewModel
    @ObservedObject var bookmarkManager: BookmarkManager
    
    private let collapsedHeight: CGFloat = 100
    private let expandedHeight: CGFloat = UIScreen.main.bounds.height * 0.8
    private let thresholdHeight: CGFloat = 250
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle and header
            VStack {
                Capsule()
                    .frame(width: 40, height: 5)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
                    .onTapGesture {
                        withAnimation {
                            isExpanded.toggle()
                            drawerHeight = isExpanded ? expandedHeight : collapsedHeight
                        }
                    }
                
                if !viewModel.groceryItems.isEmpty {
                    Text("Showing top \(viewModel.groceryItems.count) most similar to your serached")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 8)
                }
            }
            .background(Color.white)
            
            // Main content
            if isExpanded {
                List(viewModel.groceryItems, id: \.id) { item in
                    if let location = storeLocations.first(where: { $0.name == item.store }) {
                        ProductRowImproved(
                            rank: item.rank,
                            productName: item.text,
                            storeName: item.store,
                            price: item.price,
                            groceryItem: item,
                            action: {
                                zoomToLocation(latitude: location.latitude, longitude: location.longitude)
                            },
                            bookmarkManager: bookmarkManager
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                bookmarkManager.addBookmark(item)
                            } label: {
                                Label("Save", systemImage: "bookmark.fill")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                if let firstItem = viewModel.groceryItems.first {
                    ProductRowPreview(item: firstItem)
                        .padding(.horizontal)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: drawerHeight)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .offset(y: UIScreen.main.bounds.height / 2 - drawerHeight / 2)
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    let newHeight = max(collapsedHeight, min(expandedHeight, drawerHeight - value.translation.height))
                    drawerHeight = newHeight
                }
                .onEnded { _ in
                    withAnimation {
                        isExpanded = drawerHeight > thresholdHeight
                        drawerHeight = isExpanded ? expandedHeight : collapsedHeight
                    }
                }
        )
    }
    
    private func zoomToLocation(latitude: Double, longitude: Double) {
        if let mapView = mapView {
            let cameraOptions = CameraOptions(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                zoom: 14
            )
            mapView.camera.ease(to: cameraOptions, duration: 1.0)
        }
    }
}

// Improved Product Row with Rank
struct ProductRowImproved: View {
    let rank: Int
    let productName: String
    let storeName: String
    let price: String
    let groceryItem: GroceryItem
    let action: () -> Void
    @ObservedObject var bookmarkManager: BookmarkManager
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                // Rank circle
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 30, height: 30)
                    Text("#\(rank)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(productName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Image(systemName: "cart.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text(storeName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text(price)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Preview row for collapsed state
struct ProductRowPreview: View {
    let item: GroceryItem
    
    var body: some View {
        HStack {
            Text("#\(item.rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
            
            Text(item.text)
                .font(.subheadline)
                .lineLimit(1)
            
            Spacer()
            
            Text(item.price)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
        .padding(.vertical, 8)
    }
}
