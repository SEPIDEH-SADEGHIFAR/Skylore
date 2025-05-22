import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.33182, longitude: -122.03118),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        self.location = location
        self.region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

struct SwiftView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var showMap = false
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            if !showMap {
                Button("Choose Current Location") {
                    locationManager.requestLocation()
                    showMap = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else {
                Map(coordinateRegion: $locationManager.region, showsUserLocation: true, userTrackingMode: .constant(.follow))
                    .edgesIgnoringSafeArea(.all)
                    .frame(height: 400)
                
                Button("Confirm Location") {
                    // Handle the location confirmation here
                    print("Location confirmed at: \(locationManager.region.center.latitude), \(locationManager.region.center.longitude)")
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
            }
        }
    }
}

// Add this to your Info.plist:
// NSLocationWhenInUseUsageDescription - "We need your location to show you on the map" 