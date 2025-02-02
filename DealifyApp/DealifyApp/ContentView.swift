import SwiftUI
import MapboxMaps

// MARK: - ContentView

struct ContentView: View {
    @State private var drawerHeight: CGFloat = 100
    @State private var isDrawerExpanded = false
    @State private var mapView: MapView? = nil
    
    var body: some View {
        ZStack {
            // Map view using Mapbox
            MapboxMapViewRepresentable(mapView: $mapView)
                .ignoresSafeArea()

            // Floating search bar overlay
            VStack {
                FloatingSearchBar()
                Spacer()
            }
            .ignoresSafeArea(edges: .all)
            
            // Drawer with location buttons
            DrawerView(drawerHeight: $drawerHeight, isExpanded: $isDrawerExpanded, mapView: $mapView)
        }
        .ignoresSafeArea(edges: .all)
    }
}

// MARK: - FloatingSearchBar

struct FloatingSearchBar: View {
    @State private var searchText = ""
    
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
                TextField("", text: $searchText)
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
                DispatchQueue.main.async {
                    addAnnotations(to: mapView)
                }
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
        // No dynamic updates needed for this example.
    }
    
    // Add three markers using Mapbox’s Annotation API.
    private func addAnnotations(to mapView: MapView) {
        let pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
        var annotations = [PointAnnotation]()
        
        let locations = [
            (lat: 45.5088, lon: -73.554, name: "Montreal Eaton Centre"),
            (lat: 45.5017, lon: -73.5673, name: "Old Port of Montreal"),
            (lat: 45.5231, lon: -73.5817, name: "Jean-Talon Market")
        ]
        
        for location in locations {
            var annotation = PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon))
            // Use a system image for the marker (ensure you have a valid image)
            if let image = UIImage(systemName: "mappin.circle.fill") {
                annotation.image = .init(image: image, name: "mappin")
            }
            annotation.textField = location.name // Add the name as a label
            annotations.append(annotation)
        }
        
        pointAnnotationManager.annotations = annotations
    }
}

// MARK: - DrawerView

struct DrawerView: View {
    @Binding var drawerHeight: CGFloat
    @Binding var isExpanded: Bool
    @Binding var mapView: MapView?
    
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
                        LocationButton(
                            title: "Montreal Eaton Centre",
                            subtitle: "10% off produce",
                            action: {
                                print("Button tapped: Montreal Eaton Centre")
                                zoomToLocation(latitude: 45.5088, longitude: -73.554)
                            }
                        )
                        
                        LocationButton(
                            title: "Old Port of Montreal",
                            subtitle: "Daily specials",
                            action: {
                                print("Button tapped: Old Port of Montreal")
                                zoomToLocation(latitude: 45.5017, longitude: -73.5673)
                            }
                        )
                        
                        LocationButton(
                            title: "Jean-Talon Market",
                            subtitle: "Local deals",
                            action: {
                                print("Button tapped: Jean-Talon Market")
                                zoomToLocation(latitude: 45.5231, longitude: -73.5817)
                            }
                        )
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
