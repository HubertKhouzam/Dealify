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
            TextField("Search for groceries...", text: $searchText)
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 5)
        }
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
    
    var body: some View {
        VStack {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray)
                .padding(5)
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                        drawerHeight = isExpanded ? 400 : 100
                    }
                }
            Text("Best Grocery Discounts")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
            
            if isExpanded {
                Button("Montreal Eaton Centre") {
                    webView.evaluateJavaScript("zoomToLocation(45.5088, -73.554)")
                }
                .padding()
                
                Button("Old Port of Montreal") {
                    webView.evaluateJavaScript("zoomToLocation(45.5017, -73.5673)")
                }
                .padding()
                
                Button("Jean-Talon Market") {
                    webView.evaluateJavaScript("zoomToLocation(45.5231, -73.5817)")
                }
                .padding()
            }
            
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width, height: drawerHeight)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .offset(y: UIScreen.main.bounds.height / 2 - drawerHeight / 2)
        .gesture(DragGesture()
                    .onChanged { value in
                        let newHeight = max(100, min(400, drawerHeight - value.translation.height))
                        drawerHeight = newHeight
                    }
                    .onEnded { _ in
                        withAnimation {
                            isExpanded = drawerHeight > 250
                            drawerHeight = isExpanded ? 400 : 100
                        }
                    })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
