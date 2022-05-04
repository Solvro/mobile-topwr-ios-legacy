import SwiftUI
import MapKit
import ComposableArchitecture

public struct MapState: Equatable {
	public static func == (lhs: MapState, rhs: MapState) -> Bool {
		lhs.id == rhs.id
	}
	let id: UUID
	var center = MKCoordinateRegion(
		center: CLLocationCoordinate2D(
			latitude: 51.108981,
			longitude: 17.059370
		),
		span: MKCoordinateSpan(
			latitudeDelta: 0.005,
			longitudeDelta: 0.005
		)
	)
	var selectedAnnotationTitle: CustomAnnotation?
	var annotations: [CustomAnnotation]
	var newSelection: Bool = false
	
	public init(
		id: UUID,
		annotations: [CustomAnnotation]
	) {
		self.id = id
		self.annotations = annotations
	}
}

public enum MapAction: Equatable, BindableAction {
	case binding(BindingAction<MapState>)
	case annotationTapped(CustomAnnotation?)
	case speciaUseNewselectionSetter(Bool)
}

public struct MapEnvironment {
	let mainQueue: AnySchedulerOf<DispatchQueue>
	
	public init(
		mainQueue: AnySchedulerOf<DispatchQueue>
	) {
		self.mainQueue = mainQueue
	}
}

public let mapReducer = Reducer<
	MapState,
	MapAction,
	MapEnvironment
> { state, action, env in
	switch action {
	case .binding(_):
		return .none
	case .annotationTapped(let annotation):
		state.selectedAnnotationTitle = annotation
		return .none
	case .speciaUseNewselectionSetter(let newValue):
		// this action enables MKMapView to detec new annotation selection during screen reloading
		state.newSelection = newValue
		return .none
	}
}.binding()

public struct MapViewWrapper: View {
	
	let store: Store<MapState, MapAction>
	@State var tmp: String? 
	
	public init(
		store: Store<MapState, MapAction>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(store) { viewStore in
			MapView(
				annotations: viewStore.annotations,
				selectedAnnotationTitle: Binding(
					get: { viewStore.selectedAnnotationTitle },
					set: { ant in
						withAnimation {
							viewStore.send(.annotationTapped(ant))
						}
					}
				),
				region: Binding(
					get: { viewStore.center },
					set: { _ in }
				),
				wrapperViewState: viewStore
			)
		}
	}
}

#if DEBUG
struct MapView_Previews: PreviewProvider {
	static var previews: some View {
		MapViewWrapper(
			store: .init(
				initialState: MapState(
					id: UUID(),
					annotations: []
				),
				reducer: mapReducer,
				environment: MapEnvironment(mainQueue: .main.eraseToAnyScheduler())
			)
		)
	}
}
#endif

extension MKCoordinateRegion: Equatable {
	public static func == (
		lhs: MKCoordinateRegion,
		rhs: MKCoordinateRegion
	) -> Bool {
		lhs.center.latitude == rhs.center.latitude && lhs.center.longitude == rhs.center.longitude
	}
}
