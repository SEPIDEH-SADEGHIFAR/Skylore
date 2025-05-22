import SwiftUI
import MapKit

struct MapView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedLocation: SearchResult?
    @ObservedObject var locationManager = LocationManager()
    @State private var showUserLocation = false
    
    var body: some View {
        Map(coordinateRegion: $region,
            interactionModes: .all,
            showsUserLocation: showUserLocation,
            userTrackingMode: .constant(showUserLocation ? .follow : .none),
            annotationItems: selectedLocation.map { [$0] } ?? []) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                        
                        Text(location.name)
                            .font(.caption)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(4)
                    }
                }
            }
            .onAppear {
                // Request location permissions when the map appears
                locationManager.requestLocationPermission()
            }
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            // Toggle user location tracking
                            showUserLocation.toggle()
                            
                            if showUserLocation {
                                locationManager.startUpdatingLocation()
                                
                                // If we have a location, center the map on it
                                if let location = locationManager.location {
                                    region = MKCoordinateRegion(
                                        center: location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    )
                                }
                            }
                        }) {
                            Image(systemName: showUserLocation ? "location.fill" : "location")
                                .font(.title2)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            )
    }
}

#if DEBUG
struct MapView_Previews: PreviewProvider {
    @State static var previewRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3323, longitude: -122.0312),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State static var previewSelectedLocation: SearchResult? = nil
    
    static var previews: some View {
        MapView(
            region: $previewRegion,
            selectedLocation: $previewSelectedLocation
        )
    }
}
#endif 