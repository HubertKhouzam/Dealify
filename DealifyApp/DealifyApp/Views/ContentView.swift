import SwiftUI
import MapboxMaps

// MARK: - ContentView

struct ContentView: View {
    @State private var drawerHeight: CGFloat = 100
    @State private var isDrawerExpanded = false
    @State private var mapView: MapView? = nil
    @State private var searchText = ""
    @StateObject private var viewModel = StoreLocationViewModel()
    
    var body: some View {
        ZStack {
            // Map view using Mapbox
            MapboxMapViewRepresentable(mapView: $mapView, storeLocations: $viewModel.storeLocations)
                .ignoresSafeArea()

            // Floating search bar overlay
            VStack {
                FloatingSearchBar(searchText: $searchText, onSearch: { viewModel.fetchStoreLocations(searchText: searchText) })
                Spacer()
            }
            .ignoresSafeArea(edges: .all)
            
            // Drawer with location buttons
            DrawerView(drawerHeight: $drawerHeight, isExpanded: $isDrawerExpanded, mapView: $mapView, storeLocations: $viewModel.storeLocations)
        }
        .ignoresSafeArea(edges: .all)
    }
}

// Sample locations for stores
let sampleLocations: [StoreLocation] = [
    StoreLocation(name: "MAXI", latitude: 45.5088, longitude: -73.554),
    StoreLocation(name: "SUPER C", latitude: 45.5017, longitude: -73.5673),
    StoreLocation(name: "IGA", latitude: 45.5231, longitude: -73.5817),
    StoreLocation(name: "METRO", latitude: 45.515, longitude: -73.575)
]


// MARK: - MapboxMapViewRepresentable

struct MapboxMapViewRepresentable: UIViewRepresentable {
    @Binding var mapView: MapView?
    @Binding var storeLocations: [StoreLocation]
    
    func makeUIView(context: Context) -> MapView {
        // Configure Mapbox with your access token
        let resourceOptions = ResourceOptions(accessToken: "pk.eyJ1IjoiaGVpc2tldmluIiwiYSI6ImNtNm1vMGhidDBjaDgyd3EzNW5mZHh1b28ifQ.DNDca4RepMf9mYaiBsPnlw")
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions)
        let mapView = MapView(frame: .zero, mapInitOptions: mapInitOptions)
        
        // Load the map style
        mapView.mapboxMap.loadStyleURI(StyleURI.streets) { result in
            switch result {
            case .success:
                print("Map style loaded successfully")
            case .failure(let error):
                print("Failed to load map style: \(error)")
            }
        }

        // Update the mapView binding
        DispatchQueue.main.async {
            self.mapView = mapView
        }

        return mapView
    }
    
    func updateUIView(_ uiView: MapView, context: Context) {
        // Add or update markers when storeLocations changes
        let pointAnnotationManager = uiView.annotations.makePointAnnotationManager()
        var annotations = [PointAnnotation]()
        
        for location in storeLocations {
            var annotation = PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            
            // Create a circular image with a system icon inside
            if let image = createCircularImage(systemName: "cart.fill", backgroundColor: .blue, size: CGSize(width: 40, height: 40)) {
                annotation.image = .init(image: image, name: "custom_marker")
            }
            
            annotations.append(annotation)
        }
        
        pointAnnotationManager.annotations = annotations
    }
    
    // Helper function to create a circular image with a system icon inside
    private func createCircularImage(systemName: String, backgroundColor: UIColor, size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Draw a circle
            let rect = CGRect(origin: .zero, size: size)
            backgroundColor.setFill()
            context.cgContext.fillEllipse(in: rect)
            
            // Draw the system icon in the center
            if let iconImage = UIImage(systemName: systemName)?.withTintColor(.white, renderingMode: .alwaysOriginal) {
                let iconSize = CGSize(width: size.width * 0.6, height: size.height * 0.6)
                let iconRect = CGRect(
                    x: (size.width - iconSize.width) / 2,
                    y: (size.height - iconSize.height) / 2,
                    width: iconSize.width,
                    height: iconSize.height
                )
                iconImage.draw(in: iconRect)
            }
        }
    }
}


// MARK: - LocationButton

struct LocationButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle()) // Ensure the button doesn't have any default styling
        .contentShape(Rectangle()) // Make the entire button area tappable
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
