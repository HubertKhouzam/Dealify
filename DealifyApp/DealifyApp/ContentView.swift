import SwiftUI
import MapboxMaps

// MARK: - ContentView

struct ContentView: View {
    @State private var drawerHeight: CGFloat = 100
    @State private var isDrawerExpanded = false
    @State private var mapView: MapView? = nil
    @State private var searchText = ""
    @State private var storeLocations: [StoreLocation] = []
    
    var body: some View {
        ZStack {
            // Map view using Mapbox
            MapboxMapViewRepresentable(mapView: $mapView, storeLocations: $storeLocations)
                .ignoresSafeArea()

            // Floating search bar overlay
            VStack {
                FloatingSearchBar(searchText: $searchText, onSearch: fetchStoreLocations)
                Spacer()
            }
            .ignoresSafeArea(edges: .all)
            
            // Drawer with location buttons
            DrawerView(drawerHeight: $drawerHeight, isExpanded: $isDrawerExpanded, mapView: $mapView, storeLocations: $storeLocations)
        }
        .ignoresSafeArea(edges: .all)
    }
    
    // Fetch store locations based on the search text
    private func fetchStoreLocations() {
        guard !searchText.isEmpty else { return }
        
        let urlString = "https://dealify-n5sl.onrender.com/items/\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let items = try JSONDecoder().decode([GroceryItem].self, from: data)
                DispatchQueue.main.async {
                    // Extract store names and map them to locations
                    let storeNames = items.map { $0.store }
                    storeLocations = storeNames.compactMap { storeName in
                        sampleLocations.first { $0.name == storeName }
                    }
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
}

// MARK: - GroceryItem

struct GroceryItem: Codable {
    let id: Int
    let name: String
    let brand: String
    let price: String // Price is a string
    let store: String
}

// MARK: - StoreLocation

struct StoreLocation: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
}

// Sample locations for stores
let sampleLocations: [StoreLocation] = [
    StoreLocation(name: "MAXI", latitude: 45.5088, longitude: -73.554),
    StoreLocation(name: "SUPER C", latitude: 45.5017, longitude: -73.5673),
    StoreLocation(name: "IGA", latitude: 45.5231, longitude: -73.5817),
    StoreLocation(name: "METRO", latitude: 45.515, longitude: -73.575)
]

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

// MARK: - DrawerView

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
            Text("Best Grocery Discounts")
                .font(.headline)
                .padding()
                .background(Color.white)
            
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
