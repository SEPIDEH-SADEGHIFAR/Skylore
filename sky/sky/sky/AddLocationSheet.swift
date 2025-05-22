import SwiftUI
import MapKit

struct AddLocationSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedCoordinate: CLLocationCoordinate2D? = nil
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var showSearchResults = false
    @State private var centerOnUserLocation = false
    
    var onComplete: (CLLocationCoordinate2D) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                TapLocationMapView(selectedCoordinate: $selectedCoordinate,
                                   region: $region,
                                   centerOnUserLocation: centerOnUserLocation)
                    .ignoresSafeArea()
                
                // Location Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            centerOnUserLocation = true
                            // Reset after use
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                centerOnUserLocation = false
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 22))
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
                
                // Search Bar
                VStack {
                    HStack {
                        TextField("Search location...", text: $searchText)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .onSubmit {
                                searchLocation()
                            }
                        
                        Button(action: searchLocation) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing)
                    }
                    .padding(.top)
                    
                    if showSearchResults && !searchResults.isEmpty {
                        List {
                            ForEach(searchResults, id: \.self) { mapItem in
                                Button(action: {
                                    selectLocation(mapItem)
                                }) {
                                    VStack(alignment: .leading) {
                                        Text(mapItem.name ?? "Unknown Location")
                                            .font(.headline)
                                        if let address = mapItem.placemark.thoroughfare {
                                            Text(address)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: min(CGFloat(searchResults.count * 60), 300))
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .padding()
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Choose Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel Button
                ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                                .foregroundColor(.blue)
                        }
                    }
                // "Add Star" Button – only enabled if a coordinate was selected
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let coordinate = selectedCoordinate {
                            onComplete(coordinate)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Add Star")
                            .padding()
                            .frame(width: 120, height: 40)
                            .background(selectedCoordinate != nil ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(50)
                    }
                    .disabled(selectedCoordinate == nil) // Disable if no selection
                }
            }
        }
    }
    
    private func searchLocation() {
        guard !searchText.isEmpty else {
            searchResults = []
            showSearchResults = false
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response, error == nil else {
                return
            }
            
            self.searchResults = response.mapItems
            self.showSearchResults = true
        }
    }
    
    private func selectLocation(_ mapItem: MKMapItem) {
        let coordinate = mapItem.placemark.coordinate
        self.selectedCoordinate = coordinate
        
        // Update region to center on selected location
        self.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        // Hide search results
        self.showSearchResults = false
        self.searchText = mapItem.name ?? ""
    }
}
