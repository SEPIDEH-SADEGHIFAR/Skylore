import SwiftUI
import MapKit
import CoreLocation

struct AddLocationSheet: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 60)
    )
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var showSearchResults = false
    @State private var centerOnUserLocation = false
    @State private var isSatellite = false
    @State private var geocodedAddress: String?

    var onComplete: (CLLocationCoordinate2D) -> Void

    var body: some View {
        ZStack(alignment: .top) {
            TapLocationMapView(
                selectedCoordinate: $selectedCoordinate,
                region: $region,
                centerOnUserLocation: centerOnUserLocation,
                isSatellite: isSatellite,
                onCoordinateSelected: { reverseGeocode($0) }
            )
            .ignoresSafeArea()

            // Floating HUD
            VStack(spacing: 10) {
                // Header row
                HStack {
                    Button { presentationMode.wrappedValue.dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3).foregroundColor(.white)
                            .padding(12).background(.ultraThinMaterial).clipShape(Circle())
                    }

                    Spacer()

                    // Satellite toggle
                    Button { withAnimation { isSatellite.toggle() } } label: {
                        Image(systemName: isSatellite ? "map" : "globe.americas.fill")
                            .font(.title3).foregroundColor(.white)
                            .padding(12).background(.ultraThinMaterial).clipShape(Circle())
                    }

                    Spacer().frame(width: 8)

                    Button {
                        guard let coordinate = selectedCoordinate else { return }
                        onComplete(coordinate)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Confirm")
                            .fontWeight(.bold)
                            .padding(.horizontal, 20).padding(.vertical, 10)
                            .background(selectedCoordinate != nil ? Color.cyan : Color.gray.opacity(0.4))
                            .foregroundColor(selectedCoordinate != nil ? .black : .white.opacity(0.4))
                            .clipShape(Capsule())
                    }
                    .disabled(selectedCoordinate == nil)
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Search any place on Earth…", text: $searchText)
                        .foregroundColor(.white)
                        .onSubmit { searchLocation() }
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""; searchResults = []; showSearchResults = false
                        } label: {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding(.horizontal)

                // Geocoded address badge
                if let address = geocodedAddress {
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.circle.fill").foregroundColor(.cyan).font(.caption)
                        Text(address).font(.caption).foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Search results
                if showSearchResults && !searchResults.isEmpty {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(searchResults, id: \.self) { item in
                                Button { selectLocation(item) } label: {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(item.name ?? "Unknown").font(.headline).foregroundColor(.white)
                                        if let street = item.placemark.thoroughfare {
                                            Text(street).font(.caption).foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Divider().background(Color.white.opacity(0.15))
                            }
                        }
                    }
                    .frame(maxHeight: 220)
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: geocodedAddress)
            .animation(.easeInOut(duration: 0.2), value: showSearchResults)

            // Location button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        centerOnUserLocation = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            centerOnUserLocation = false
                        }
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.cyan)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 6)
                    }
                    .padding()
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Helpers

    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) {
        CLGeocoder().reverseGeocodeLocation(
            CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        ) { placemarks, _ in
            DispatchQueue.main.async {
                guard let p = placemarks?.first else { return }
                var parts: [String] = []
                if let name = p.name            { parts.append(name) }
                if let city = p.locality        { parts.append(city) }
                if let country = p.country      { parts.append(country) }
                self.geocodedAddress = parts.joined(separator: ", ")
            }
        }
    }

    private func searchLocation() {
        guard !searchText.isEmpty else {
            searchResults = []; showSearchResults = false; return
        }
        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = searchText
        req.region = region
        MKLocalSearch(request: req).start { response, _ in
            guard let r = response else { return }
            self.searchResults = r.mapItems
            self.showSearchResults = true
        }
    }

    private func selectLocation(_ item: MKMapItem) {
        let coord = item.placemark.coordinate
        selectedCoordinate = coord
        region = MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        showSearchResults = false
        searchText = item.name ?? ""
        reverseGeocode(coord)
    }
}
