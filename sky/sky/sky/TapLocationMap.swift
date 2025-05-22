//  TapLocationMapView.swift

import SwiftUI
import MapKit
import CoreLocation

struct TapLocationMapView: UIViewRepresentable {
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @Binding var region: MKCoordinateRegion
    var centerOnUserLocation: Bool = false

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        mapView.showsUserLocation = true
        
        // Set up location manager
        let locationManager = CLLocationManager()
        locationManager.delegate = context.coordinator
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Request authorization
        locationManager.requestWhenInUseAuthorization()
        
        context.coordinator.locationManager = locationManager

        // Add tap gesture recognizer to the map view
        let tapGesture = UITapGestureRecognizer(target: context.coordinator,
                                                action: #selector(context.coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update the region when needed
        uiView.setRegion(region, animated: true)
        
        // Center on user location if requested
        if centerOnUserLocation {
            context.coordinator.centerMapOnUserLocation(uiView)
        }
        
        // Remove all annotations and add one for the selected coordinate (if available)
        uiView.removeAnnotations(uiView.annotations)
        if let coordinate = selectedCoordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            uiView.addAnnotation(annotation)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parent: TapLocationMapView
        var locationManager: CLLocationManager?
        
        init(_ parent: TapLocationMapView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            guard let mapView = gestureRecognizer.view as? MKMapView else { return }
            let tapPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
            
            DispatchQueue.main.async {
                self.parent.selectedCoordinate = coordinate
                self.parent.region.center = coordinate // Update region center to the tapped coordinate
            }
        }
        
        func centerMapOnUserLocation(_ mapView: MKMapView) {
            if let userLocation = locationManager?.location?.coordinate {
                let region = MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                
                DispatchQueue.main.async {
                    self.parent.region = region
                }
            }
        }
        
        // Handle location authorization changes
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager?.startUpdatingLocation()
            default:
                break
            }
        }
    }
}
