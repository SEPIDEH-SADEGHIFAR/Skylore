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
        ZStack(alignment: .top) {
            TapLocationMapView(selectedCoordinate: $selectedCoordinate,
                               region: $region,
                               centerOnUserLocation: centerOnUserLocation)
                .ignoresSafeArea()
            
            // Floating Top HUD
            VStack(spacing: 15) {
                // Header Bar
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if let coordinate = selectedCoordinate {
                            onComplete(coordinate)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Confirm")
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(selectedCoordinate != nil ? Color.cyan : Color.gray.opacity(0.5))
                            .foregroundColor(selectedCoordinate != nil ? .black : .white.opacity(0.5))
                            .clipShape(Capsule())
                    }
                    .disabled(selectedCoordinate == nil)
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Search sectors...", text: $searchText)
                        .foregroundColor(.white)
                        .onSubmit { searchLocation() }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Search Results Dropdown
                if showSearchResults && !searchResults.isEmpty {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(searchResults, id: \.self) { mapItem in
                                Button(action: { selectLocation(mapItem) }) {
                                    VStack(alignment: .leading) {
                                        Text(mapItem.name ?? "Unknown Location")
                                            .font(.headline).foregroundColor(.white)
                                        if let address = mapItem.placemark.thoroughfare {
                                            Text(address).font(.caption).foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Divider().background(Color.white.opacity(0.2))
                            }
                        }
                    }
                    .frame(maxHeight: 250)
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
            }

            // Location Button (Bottom Right)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        centerOnUserLocation = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { centerOnUserLocation = false }
                    }) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.cyan)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 5)
                    }
                    .padding()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Search Logic
    
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
