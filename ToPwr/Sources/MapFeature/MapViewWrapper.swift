import SwiftUI
import MapKit
import ComposableArchitecture

public struct MapWrapper: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        public static func == (lhs: MapWrapper.State, rhs: MapWrapper.State) -> Bool {
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
        var selectedAnnotation: CustomAnnotation?
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
    
    // MARK: - Action
    public enum Action: Equatable {
        case annotationTapped(CustomAnnotation?)
        case speciaUseNewselectionSetter(Bool)
        case annotationTappedInList(CustomAnnotation?)
        case annotationDeselected
    }
    
    // MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .annotationTapped(let annotation):
                state.selectedAnnotation = annotation
                if annotation == nil {
                    return .init(value: .annotationDeselected)
                }    else {
                    return .none
                }
            case .annotationTappedInList(let annotation):
                state.selectedAnnotation = annotation
                return .none
            case .speciaUseNewselectionSetter(let newValue):
                // this effect enables MKMapView to detect new annotation selection during screen reloading
                state.newSelection = newValue
                return .none
            case .annotationDeselected:
                return .none
            }
        }
    }
}

public struct MapViewWrapper: View {
    
    let store: StoreOf<MapWrapper>
    
    public init(store: StoreOf<MapWrapper>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            MapView(
                annotations: viewStore.annotations,
                selectedAnnotationTitle: Binding(
                    get: {
                        viewStore.selectedAnnotation
                    },
                    set: { ant in
                        // program doesn't go here when setting value from within reducer
                        // probably have to rewrite this like search view.
                        viewStore.send(.annotationTapped(ant))
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
// MARK: - Mock
extension MapWrapper.State {
    static let mock: Self = .init(id: UUID(), annotations: [])
}

// MARK: - Preview
struct MapViewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        MapViewWrapper(
            store: .init(
                initialState: .mock,
                reducer: MapWrapper()
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
