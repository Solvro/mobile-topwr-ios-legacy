import SwiftUI
import ComposableArchitecture

//MARK: - STATE
public struct MapFeatureState: Equatable {
    public init(){}
}
//MARK: - ACTION
public enum MapFeatureAction: Equatable {
    case buttonTapped
}

//MARK: - ENVIRONMENT
public struct MapFeatureEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let mapFeatureReducer = Reducer<
    MapFeatureState,
    MapFeatureAction,
    MapFeatureEnvironment
> { state, action, environment in
  switch action {
  case .buttonTapped:
    return .none
  }
}

//MARK: - VIEW
public struct MapFeatureView: View {
    let store: Store<MapFeatureState, MapFeatureAction>

    
    public init(
        store: Store<MapFeatureState, MapFeatureAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                MapView()
            }
            .ignoresSafeArea()
        }
    }
}

#if DEBUG
struct MapFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        MapFeatureView(
            store: Store(
                initialState: .init(),
                reducer: mapFeatureReducer,
                environment: .init(mainQueue: .immediate)
            )
        )
    }
}
#endif
