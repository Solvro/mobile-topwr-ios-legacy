import MapKit
import UIKit
import SwiftUI
import Common

struct MapView: UIViewRepresentable {
    let mapViewDelegate = MapViewDelegate()
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 51.108981,
                longitude: 17.059370
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.005,
                longitudeDelta: 0.005
            )
        )
        
        view.addOverlays(MapCoordinator().parseGeoJSON())
        view.region = region
        view.pointOfInterestFilter = .excludingAll
        view.delegate = mapViewDelegate
        view.translatesAutoresizingMaskIntoConstraints = false
    }
}

class MapViewDelegate: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? MKPolygon {
            if polygon.title == "buildings" {
                #warning("TODO: string builings, Annotation (titles for builidngs")
                let render = MKPolygonRenderer(polygon: polygon)
                render.fillColor = UIColor(K.MapColors.buildings1).withAlphaComponent(0.8)
                return render
            }
        }
        let renderer = MKPolylineRenderer(overlay: overlay)
        return renderer
    }
}
