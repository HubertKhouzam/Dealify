import SwiftUI
import WebKit

struct ContentView: View {
    @State private var drawerHeight: CGFloat = 100
    @State private var isDrawerExpanded = false
    @State private var webView: WKWebView = WKWebView()
    
    var body: some View {
        ZStack {
            VStack {
                Spacer().frame(height: 10)
                MapView(webView: $webView)
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                FloatingSearchBar()
                Spacer()
            }
            .edgesIgnoringSafeArea(.top)
            
            DrawerView(drawerHeight: $drawerHeight, isExpanded: $isDrawerExpanded, webView: $webView)
                .frame(maxWidth: UIScreen.main.bounds.width)
        }
    }
}

struct FloatingSearchBar: View {
    @State private var searchText = ""
    
    var body: some View {
        HStack {
            // Search icon
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)
            
            // TextField with dynamic placeholder
            ZStack(alignment: .leading) {
                // Placeholder text
                if searchText.isEmpty {
                    Text("Search for groceries...")
                        .foregroundColor(.white.opacity(0.7)) // Placeholder color
                        .padding(.leading, 4) // Align with TextField text
                }
                
                // TextField
                TextField("", text: $searchText)
                    .foregroundColor(.white) // Text color
                    .tint(.white) // Cursor color
            }
        }
        .padding()
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(radius: 5)
        .padding(.horizontal)
        .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
        .padding(.top, 50)
        .background(Color.clear)
        .position(x: UIScreen.main.bounds.width / 2, y: 100)
        .zIndex(1)
    }
}

struct MapView: UIViewRepresentable {
    @Binding var webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        let htmlString = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name='viewport' content='initial-scale=1.0, user-scalable=no'>
            <script src='https://unpkg.com/leaflet/dist/leaflet.js'></script>
            <link rel='stylesheet' href='https://unpkg.com/leaflet/dist/leaflet.css'/>
            <style>
                body { margin: 0; padding: 0; }
                #map { width: 100vw; height: 100vh; }
                .leaflet-popup-content-wrapper { border-radius: 10px; }
                .leaflet-marker-icon {
                                    color: red;
                                    border-radius: 50%;
                                    width: 27px !important;
                                    height: 40px !important
                                }
            </style>
        </head>
        <body>
            <div id='map'></div>
            <script>
                var map = L.map('map').setView([45.5017, -73.5673], 12);
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    attribution: '&copy; OpenStreetMap contributors',
                    detectRetina: true
                }).addTo(map);

                var locations = [
                    {lat: 45.5088, lon: -73.554, name: "Montreal Eaton Centre"},
                    {lat: 45.5017, lon: -73.5673, name: "Old Port of Montreal"},
                    {lat: 45.5231, lon: -73.5817, name: "Jean-Talon Market"}
                ];
        
                locations.forEach(function(location) {
                    L.marker([location.lat, location.lon]).addTo(map)
                        .bindPopup(`<b>${location.name}</b>`)
                        .openPopup();
                });

                function zoomToLocation(lat, lon) {
                    map.setView([lat, lon], 15);
                }
            </script>
        </body>
        </html>
        """
        webView.loadHTMLString(htmlString, baseURL: nil)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct DrawerView: View {
    @Binding var drawerHeight: CGFloat
    @Binding var isExpanded: Bool
    @Binding var webView: WKWebView
    
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
            
            // Expanded content
            if isExpanded {
                ScrollView {
                    VStack(spacing: 16) {
                        LocationButton(
                            title: "Montreal Eaton Centre",
                            subtitle: "10% off produce",
                            action: { webView.evaluateJavaScript("zoomToLocation(45.5088, -73.554)") }
                        )
                        
                        LocationButton(
                            title: "Old Port of Montreal",
                            subtitle: "Daily specials",
                            action: { webView.evaluateJavaScript("zoomToLocation(45.5017, -73.5673)") }
                        )
                        
                        LocationButton(
                            title: "Jean-Talon Market",
                            subtitle: "Local deals",
                            action: { webView.evaluateJavaScript("zoomToLocation(45.5231, -73.5817)") }
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
}

// Reusable LocationButton component
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
