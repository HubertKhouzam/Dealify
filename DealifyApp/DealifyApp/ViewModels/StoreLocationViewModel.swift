import Foundation
import Combine

class StoreLocationViewModel: ObservableObject {
    @Published var storeLocations: [StoreLocation] = []
    @Published var groceryItems: [GroceryItem] = [] // Holds the fetched grocery items
    
    func fetchStoreLocations(searchText: String) {
        guard !searchText.isEmpty else { return }
        
        // Construct the URL with the search text
        let urlString = "https://dealify-n5sl.onrender.com/items/search/\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        // Perform the network request
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                // Decode the JSON data into an array of GroceryItem
                let items = try JSONDecoder().decode([GroceryItem].self, from: data)
                
                // Update the published properties on the main thread
                DispatchQueue.main.async {
                    self?.groceryItems = items // Store the fetched grocery items
                    
                    // Map the grocery items to store locations (if applicable)
                    self?.storeLocations = items.compactMap { item in
                        sampleLocations.first { $0.name == item.store }
                    }
                }
                
                print("Fetched items: \(items)")
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
}
