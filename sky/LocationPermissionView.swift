import SwiftUI
import CoreLocation

struct LocationPermissionView: View {
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                requestLocationPermissionView
                
            case .restricted, .denied:
                locationPermissionDeniedView
                
            case .authorizedWhenInUse, .authorizedAlways:
                Text("Location permission granted!")
                    .padding()
                
            @unknown default:
                Text("Unknown authorization status")
                    .padding()
            }
        }
    }
    
    var requestLocationPermissionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle")
                .font(.system(size: 56))
                .foregroundColor(.blue)
            
            Text("Location Access Required")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("This app needs access to your location to show your position on the map and provide navigation features.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                locationManager.requestLocationPermission()
            }) {
                Text("Allow Location Access")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    var locationPermissionDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.slash")
                .font(.system(size: 56))
                .foregroundColor(.red)
            
            Text("Location Access Denied")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("You have denied location access. To use all features of this app, please enable location access in Settings.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Open Settings")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
} 