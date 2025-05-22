extension LocationManager {
    // Start monitoring significant location changes
    func startMonitoringSignificantLocationChanges() {
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    // Set up region monitoring for geofencing
    func startMonitoringRegion(center: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String) {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            locationManager.startMonitoring(for: region)
        }
    }
    
    // Configure background updates
    func enableBackgroundLocationUpdates() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
} 