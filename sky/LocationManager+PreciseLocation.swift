extension LocationManager {
    // Check if precise location is enabled
    var isPreciseLocationEnabled: Bool {
        if #available(iOS 14.0, *) {
            return locationManager.accuracyAuthorization == .fullAccuracy
        } else {
            return true // Always true for iOS 13 and below
        }
    }
    
    // Handle precise location accuracy changes (iOS 14+)
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            
            // Start updating location if permission is granted
            if manager.authorizationStatus == .authorizedWhenInUse || 
               manager.authorizationStatus == .authorizedAlways {
                self.locationManager.startUpdatingLocation()
            }
            
            // Check for precise location
            if manager.accuracyAuthorization == .reducedAccuracy {
                // Show alert or UI to request precise location
                print("Precise location is disabled. Some features may not work accurately.")
            }
        }
    }
    
    // Request temporary precise location if needed
    func requestTemporaryPreciseLocationAuthorization(purposeKey: String) {
        if #available(iOS 14.0, *) {
            locationManager.requestTemporaryFullAccuracyAuthorization(
                withPurposeKey: purposeKey
            )
        }
    }
} 