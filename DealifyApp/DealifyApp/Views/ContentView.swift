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
            // Map view
            MapboxMapViewRepresentable(mapView: $mapView, storeLocations: $viewModel.storeLocations)
                .ignoresSafeArea()
            
            VStack {
                // Search bar
                FloatingSearchBar(
                    searchText: $searchText,
                    onSearch: { viewModel.fetchStoreLocations(searchText: searchText) }
                )
                Spacer()
            }
            .ignoresSafeArea(edges: .all)
            
            // Products drawer
            DrawerView(
                drawerHeight: $drawerHeight,
                isExpanded: $isDrawerExpanded,
                mapView: $mapView,
                storeLocations: $viewModel.storeLocations,
                viewModel: viewModel
            )
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
    
    // Montreal coordinates
    private let montrealCenter = CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673)
    
    func makeUIView(context: Context) -> MapView {
        let resourceOptions = ResourceOptions(accessToken: "pk.eyJ1IjoiaGVpc2tldmluIiwiYSI6ImNtNm1vMGhidDBjaDgyd3EzNW5mZHh1b28ifQ.DNDca4RepMf9mYaiBsPnlw")
        
        // Create camera options to set initial position
        let cameraOptions = CameraOptions(
            center: montrealCenter,
            zoom: 12.0, // Adjust this value to set the initial zoom level
            bearing: 0,
            pitch: 0
        )
        
        // Include camera options in map initialization
        let mapInitOptions = MapInitOptions(
            resourceOptions: resourceOptions,
            cameraOptions: cameraOptions,
            styleURI: StyleURI.streets
        )
        
        let mapView = MapView(frame: .zero, mapInitOptions: mapInitOptions)
        
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
    let productName: String    // New: Product name
    let storeName: String     // Changed: Store name (was title)
    let price: String         // New: Price
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(productName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(storeName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(price)
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding(.trailing, 8)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}
// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
