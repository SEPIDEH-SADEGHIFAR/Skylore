import SwiftUI
import MapKit

struct SearchResult: Identifiable {
    let id = UUID()
    let name: String
    let address: String?
    let coordinate: CLLocationCoordinate2D
}

class SearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    private let completer = MKLocalSearchCompleter()
    
    @Published var results: [MKLocalSearchCompletion] = []
    @Published var isSearching = false
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .pointOfInterest
    }
    
    func search(query: String) {
        isSearching = true
        completer.queryFragment = query
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.results = completer.results
            self.isSearching = false
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error searching for locations: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.isSearching = false
        }
    }
}

struct LocationSearchView: View {
    @StateObject private var searchCompleter = SearchCompleter()
    @Binding var region: MKCoordinateRegion
    @Binding var selectedResult: SearchResult?
    @State private var searchText = ""
    @State private var isShowingResults = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search for a location", text: $searchText)
                    .onChange(of: searchText) { newValue in
                        if !newValue.isEmpty {
                            searchCompleter.search(query: newValue)
                            isShowingResults = true
                        } else {
                            isShowingResults = false
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        isShowingResults = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                if searchCompleter.isSearching {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
            
            if isShowingResults {
                List {
                    ForEach(searchCompleter.results, id: \.self) { result in
                        Button(action: {
                            searchLocation(from: result)
                        }) {
                            VStack(alignment: .leading) {
                                Text(result.title)
                                    .font(.headline)
                                Text(result.subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 2)
                .frame(maxHeight: 300)
            }
        }
        .padding()
    }
    
    func searchLocation(from completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let response = response, error == nil else {
                print("Error searching for location: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let mapItem = response.mapItems.first else { return }
            
            DispatchQueue.main.async {
                self.region = MKCoordinateRegion(
                    center: mapItem.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                
                self.selectedResult = SearchResult(
                    name: mapItem.name ?? completion.title,
                    address: mapItem.placemark.title,
                    coordinate: mapItem.placemark.coordinate
                )
                
                self.searchText = completion.title
                self.isShowingResults = false
            }
        }
    }
} 