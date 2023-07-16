//import MapKit
//import UIKit
//import SwiftUI
//import Common
//import ComposableArchitecture
//import Combine
//
//struct MapView: UIViewRepresentable {
//	var annotations: [CustomAnnotation]
//	@Binding var selectedAnnotationTitle: CustomAnnotation? {
//		mutating willSet (newValue) {
//			if newValue == nil {
//				selectionTmpCopy = selectedAnnotationTitle
//			}
//		}
//	}
//	var selectionTmpCopy: CustomAnnotation? = nil
//	@Binding var region: MKCoordinateRegion
//	@ObservedObject var wrapperViewState: ViewStore<MapState,MapAction>
//	
//	func makeUIView(context: Context) -> MKMapView {
//		let view = MKMapView(frame: .zero)
//		view.delegate = context.coordinator
//		view.region = region // this must be here so that animation can work
//		if let safePastSelection = selectionTmpCopy {
//			view.deselectAnnotation(safePastSelection, animated: true)
//		}
//		return view
//	}
//	
//	func updateUIView(_ view: MKMapView, context: Context) {
//        #warning("TODO: Overlays on maps")
//// it caused problem with map -> We should think about it how to add layers.
////		view.addOverlays(MapCoordinator().parseGeoJSON())
//		view.addAnnotations(annotations)
//		view.pointOfInterestFilter = .excludingAll
//		view.translatesAutoresizingMaskIntoConstraints = false
//		if wrapperViewState.newSelection == true {
//			if let annotation = annotations.first(
//				where: { $0.title == wrapperViewState.selectedAnnotation?.title ?? ""}
//			) {
//				view.selectAnnotation(annotation, animated: true)
//			}
//		}
//	}
//	
//	func makeCoordinator() -> MapViewDelegate {
//		MapViewDelegate(self)
//	}
//	
//	class MapViewDelegate: NSObject, MKMapViewDelegate {
//		
//		var parent: MapView
//		
//		public init(
//			_ parent: MapView
//		) {
//			self.parent = parent
//		}
//		
//		func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//			let id = "Building"
//			let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
//			
//			annotationView.glyphImage = UIImage(named: "hat")
//			annotationView.markerTintColor = UIColor(K.Colors.lightGray)
//			annotationView.glyphTintColor = UIColor(annotationView.isSelected ? .orange : K.Colors.firstColorDark)
//			annotationView.isDraggable = false
//			annotationView.canShowCallout = false
//			annotationView.titleVisibility = .hidden
//			return annotationView
//		}
//		
//		func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//			if let polygon = overlay as? MKPolygon {
//				if polygon.title == "buildings" {
//					let render = MKPolygonRenderer(polygon: polygon)
//					render.fillColor = UIColor(K.MapColors.buildings1).withAlphaComponent(0.8)
//					return render
//				}
//			}
//			let renderer = MKPolylineRenderer(overlay: overlay)
//			return renderer
//		}
//		
//		func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//			if let safeAnnotation = view.annotation as? CustomAnnotation {
//				parent.selectedAnnotationTitle = safeAnnotation
//				mapView.setCenter(safeAnnotation.coordinate, animated: true)
//				parent.wrapperViewState.send(.speciaUseNewselectionSetter(false))
//			}
//		}
//		
//		func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//			parent.selectedAnnotationTitle = nil
//		}
//	}
//}
//
//public class CustomAnnotation: NSObject, MKAnnotation {
//	
//	public var coordinate: CLLocationCoordinate2D
//	public var title: String?
//	public var id: Int
//	
//	public init(
//		coordinate: CLLocationCoordinate2D,
//		title: String? = nil,
//		id: Int
//	) {
//		self.coordinate = coordinate
//		self.title = title
//		self.id = id
//	}
//}
