import SwiftUI
import MapKit
import CoreLocation

struct TapLocationMapView: UIViewRepresentable {
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @Binding var region: MKCoordinateRegion
    var centerOnUserLocation: Bool = false
    var isSatellite: Bool = false
    var onCoordinateSelected: ((CLLocationCoordinate2D) -> Void)? = nil

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.setRegion(region, animated: false)
        map.showsUserLocation = true
        map.showsCompass = false

        let locationManager = CLLocationManager()
        locationManager.delegate = context.coordinator
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        context.coordinator.locationManager = locationManager

        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handleTap(_:))
        )
        map.addGestureRecognizer(tap)

        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        map.setRegion(region, animated: true)
        map.mapType = isSatellite ? .hybridFlyover : .mutedStandard

        if centerOnUserLocation {
            context.coordinator.centerOnUser(map)
        }

        map.removeAnnotations(map.annotations)
        if let coord = selectedCoordinate {
            let pin = MKPointAnnotation()
            pin.coordinate = coord
            map.addAnnotation(pin)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    // MARK: - Coordinator
    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parent: TapLocationMapView
        var locationManager: CLLocationManager?

        init(_ parent: TapLocationMapView) { self.parent = parent }

        @objc func handleTap(_ gr: UITapGestureRecognizer) {
            guard let map = gr.view as? MKMapView else { return }
            let coord = map.convert(gr.location(in: map), toCoordinateFrom: map)
            DispatchQueue.main.async {
                self.parent.selectedCoordinate = coord
                self.parent.region.center = coord
                self.parent.onCoordinateSelected?(coord)
            }
        }

        func centerOnUser(_ map: MKMapView) {
            guard let coord = locationManager?.location?.coordinate else { return }
            let region = MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            DispatchQueue.main.async { self.parent.region = region }
        }

        // Custom cyan star annotation
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            let id = "starPin"
            let view = (mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView)
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
            view.annotation = annotation
            view.markerTintColor = .cyan
            view.glyphImage = UIImage(systemName: "star.fill")
            view.animatesWhenAdded = true
            return view
        }

        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            if manager.authorizationStatus == .authorizedWhenInUse
                || manager.authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }
}
