import SwiftUI
import AVFoundation
import MapboxMaps

// MARK: - ContentView
struct ContentView: View {
    @State private var drawerHeight: CGFloat = 100
    @State private var isDrawerExpanded = false
    @State private var mapView: MapView? = nil
    @State private var searchText = ""
    @State private var showingBookmarks = false
    @State private var isCameraViewActive = false // State variable for camera navigation
    @State private var showCameraAccessAlert = false // State variable for camera access alert
    @StateObject private var viewModel = StoreLocationViewModel()
    @StateObject private var bookmarkManager = BookmarkManager()
    @State private var uploadedGroceryItems: [GroceryItem] = []
    @State private var isShowingUploadedItems = false
    
    var body: some View {
        ZStack {
            // Map view using Mapbox
            MapboxMapViewRepresentable(
                mapView: $mapView,
                storeLocations: $viewModel.storeLocations
            )
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
                viewModel: viewModel,
                bookmarkManager: bookmarkManager
            )

            // Floating buttons
            VStack {
                Spacer()

                // Camera FAB
                HStack {
                    Spacer()
                    Button(action: {
                        print("Camera button tapped") // Debug print

                        // Check camera authorization status
                        switch AVCaptureDevice.authorizationStatus(for: .video) {
                        case .authorized:
                            print("Camera access authorized")
                            self.isCameraViewActive = true // Navigate to CameraView
                        case .notDetermined:
                            print("Camera access not determined")
                            AVCaptureDevice.requestAccess(for: .video) { granted in
                                DispatchQueue.main.async {
                                    if granted {
                                        print("Camera access granted")
                                        self.isCameraViewActive = true // Navigate to CameraView
                                    } else {
                                        print("Camera access denied")
                                        self.showCameraAccessAlert = true // Show alert
                                    }
                                }
                            }
                        case .denied:
                            print("Camera access denied")
                            self.showCameraAccessAlert = true // Show alert
                        case .restricted:
                            print("Camera access restricted")
                        @unknown default:
                            print("Unknown camera authorization status")
                        }
                    }) {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.green)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }

                // Bookmark FAB
                HStack {
                    Spacer()
                    Button {
                        showingBookmarks = true
                    } label: {
                        Image(systemName: "bookmark.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, drawerHeight + 20) // Adjust for drawer height
                }
            }
        }
        .ignoresSafeArea(edges: .all)
        .sheet(isPresented: $showingBookmarks) {
            BookmarkView(bookmarkManager: bookmarkManager)
        }
        .alert(isPresented: $showCameraAccessAlert) {
            Alert(
                title: Text("Camera Access Denied"),
                message: Text("Please grant camera access in Settings to use this feature."),
                dismissButton: .default(Text("OK"))
            )
        }
        .fullScreenCover(isPresented: $isCameraViewActive) {
                CameraView(viewModel: viewModel)
            }
        }
    }


// MARK: - CameraView
struct CameraView2: View {
    var body: some View {
        Text("Camera View")
            .navigationBarTitle("Camera", displayMode: .inline)
    }
}

// Sample locations for stores
let sampleLocations: [StoreLocation] = [
    StoreLocation(name: "Maxi", latitude: 45.5088, longitude: -73.554),
    StoreLocation(name: "Maxi", latitude: 45.504974, longitude: -73.7097698),
    StoreLocation(name: "Maxi", latitude: 45.4585, longitude: -73.66029),
    StoreLocation(name: "Maxi", latitude: 45.517572, longitude: -73.77055),
    StoreLocation(name: "Maxi", latitude: 45.541089, longitude: -73.631608),
    StoreLocation(name: "Super C", latitude: 45.52073, longitude: -73.5673),
    StoreLocation(name: "Super C", latitude: 45.5155983, longitude: -73.7675634),
    StoreLocation(name: "Super C", latitude: 45.550559, longitude: -73.616101),
    StoreLocation(name: "Super C", latitude: 45.4801326, longitude: -73.6478927),
    StoreLocation(name: "Super C", latitude: 45.6023902, longitude: -73.7218227),
    StoreLocation(name: "IGA", latitude: 45.5231, longitude: -73.5817),
    StoreLocation(name: "IGA", latitude: 45.4976893, longitude: -73.678498),
    StoreLocation(name: "METRO", latitude: 45.515, longitude: -73.575),
    StoreLocation(name: "METRO", latitude: 45.4790321, longitude: -73.69254),
    StoreLocation(name: "METRO", latitude: 45.5399458, longitude: -73.63661527),
    StoreLocation(name: "METRO", latitude: 45.510347, longitude: -73.611071),
    StoreLocation(name: "Provigo", latitude: 45.5015, longitude: -73.5725),
    StoreLocation(name: "Provigo", latitude: 45.53083, longitude: -73.6620972),
    StoreLocation(name: "Provigo", latitude: 45.5156519, longitude: -73.755459)
    
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
