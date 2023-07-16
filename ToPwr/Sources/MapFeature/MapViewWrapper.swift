//import SwiftUI
//import MapKit
//import ComposableArchitecture
//
//public struct MapState: Equatable {
//	public static func == (lhs: MapState, rhs: MapState) -> Bool {
//		lhs.id == rhs.id
//	}
//	let id: UUID
//	var center = MKCoordinateRegion(
//		center: CLLocationCoordinate2D(
//			latitude: 51.108981,
//			longitude: 17.059370
//		),
//		span: MKCoordinateSpan(
//			latitudeDelta: 0.005,
//			longitudeDelta: 0.005
//		)
//	)
//	var selectedAnnotation: CustomAnnotation?
//	var annotations: [CustomAnnotation]
//	var newSelection: Bool = false
//	
//	public init(
//		id: UUID,
//		annotations: [CustomAnnotation]
//	) {
//		self.id = id
//		self.annotations = annotations
//	}
//}
//
//public enum MapAction: Equatable {
//	case annotationTapped(CustomAnnotation?)
//	case speciaUseNewselectionSetter(Bool)
//	case annotationTappedInList(CustomAnnotation?)
//	case annotationDeselected
//}
//
//public struct MapEnvironment {
//	let mainQueue: AnySchedulerOf<DispatchQueue>
//	
//	public init(
//		mainQueue: AnySchedulerOf<DispatchQueue>
//	) {
//		self.mainQueue = mainQueue
//	}
//}
//
//public let mapReducer = Reducer<
//	MapState,
//	MapAction,
//	MapEnvironment
//> { state, action, env in
//	switch action {
//	case .annotationTapped(let annotation):
//		state.selectedAnnotation = annotation
//		if annotation == nil {
//			return .init(value: .annotationDeselected)
//		}	else {
//			return .none
//		}
//	case .annotationTappedInList(let annotation):
//		state.selectedAnnotation = annotation
//		return .none
//	case .speciaUseNewselectionSetter(let newValue):
//		// this effect enables MKMapView to detect new annotation selection during screen reloading
//		state.newSelection = newValue
//		return .none
//	case .annotationDeselected:
//		return .none
//	}
//}
//
//public struct MapViewWrapper: View {
//	
//	let store: Store<MapState, MapAction>
//	
//	public init(
//		store: Store<MapState, MapAction>
//	) {
//		self.store = store
//	}
//	
//	public var body: some View {
//		WithViewStore(store) { viewStore in
//			MapView(
//				annotations: viewStore.annotations,
//				selectedAnnotationTitle: Binding(
//					get: {
//						viewStore.selectedAnnotation
//					},
//					set: { ant in
//						// program doesn't go here when setting value from within reducer
//						// probably have to rewrite this like search view.
//						viewStore.send(.annotationTapped(ant))
//					}
//				),
//				region: Binding(
//					get: { viewStore.center },
//					set: { _ in }
//				),
//				wrapperViewState: viewStore
//			)
//		}
//	}
//}
//
//#if DEBUG
//struct MapView_Previews: PreviewProvider {
//	static var previews: some View {
//		MapViewWrapper(
//			store: .init(
//				initialState: MapState(
//					id: UUID(),
//					annotations: []
//				),
//				reducer: mapReducer,
//				environment: MapEnvironment(mainQueue: .main.eraseToAnyScheduler())
//			)
//		)
//	}
//}
//#endif
//
//extension MKCoordinateRegion: Equatable {
//	public static func == (
//		lhs: MKCoordinateRegion,
//		rhs: MKCoordinateRegion
//	) -> Bool {
//		lhs.center.latitude == rhs.center.latitude && lhs.center.longitude == rhs.center.longitude
//	}
//}
