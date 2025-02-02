//
//  DrawerView.swift
//  DealifyApp
//
//  Created by Hubert Khouzam on 2025-02-01.
//

import Foundation
import SwiftUI
import MapboxMaps

struct DrawerView: View {
    @Binding var drawerHeight: CGFloat
    @Binding var isExpanded: Bool
    @Binding var mapView: MapView?
    @Binding var storeLocations: [StoreLocation]
    @ObservedObject var viewModel: StoreLocationViewModel
    
    // Constants for drawer heights
    private let collapsedHeight: CGFloat = 100
    private let expandedHeight: CGFloat = 400
    private let thresholdHeight: CGFloat = 250
    
    var body: some View {
        VStack(spacing: 0) {
            // Draggable handle
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
            
            // Results count
            if !viewModel.groceryItems.isEmpty {
                Text("\(viewModel.groceryItems.count) results found")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)
            }
            
            // Product list
            if isExpanded {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.groceryItems, id: \.id) { item in
                            if let location = storeLocations.first(where: { $0.name == item.store }) {
                                ProductRow(
                                    productName: item.name,
                                    storeName: item.store,
                                    price: item.price,
                                    action: {
                                        zoomToLocation(latitude: location.latitude, longitude: location.longitude)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                // Preview of first few items when collapsed
                if let firstItem = viewModel.groceryItems.first {
                    Text(firstItem.name)
                        .font(.headline)
                        .padding(.bottom, 4)
                }
            }
            
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width, height: drawerHeight)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .offset(y: UIScreen.main.bounds.height / 2 - drawerHeight / 2)
        .gesture(
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
                zoom: 15
            )
            mapView.camera.ease(to: cameraOptions, duration: 1.0)
        }
    }
}

// MARK: - ProductRow
struct ProductRow: View {
    let productName: String
    let storeName: String
    let price: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                // Product info
                VStack(alignment: .leading, spacing: 4) {
                    Text(productName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
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
                
                // Price
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
