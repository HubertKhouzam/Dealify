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
            
            // Header
            HStack {
                Image(systemName: "trash")
                    .foregroundColor(.black)
                
                Text("Delete")
                    .foregroundColor(.black)
                    .padding(.leading, 4)
                    
            }
            
            // Expanded content: list of location buttons
            if isExpanded {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(storeLocations) { location in
                            LocationButton(
                                title: location.name,
                                subtitle: "Tap to view location",
                                action: {
                                    zoomToLocation(latitude: location.latitude, longitude: location.longitude)
                                }
                            )
                        }
                    }
                    .padding()
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
    
    // Zooms the map (if available) to the given coordinates with a zoom level of 15.
    private func zoomToLocation(latitude: Double, longitude: Double) {
        if let mapView = mapView {
            print("Zooming to location: (\(latitude), \(longitude))")
            let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), zoom: 15)
            
            // Animate the camera movement
            mapView.camera.ease(to: cameraOptions, duration: 1.0) { (_) in
                // Completion handler if needed
                print("Camera movement completed")
            }
        } else {
            print("mapView is nil")
        }
    }
}
