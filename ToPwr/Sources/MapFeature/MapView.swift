import SwiftUI
import ComposableArchitecture

//MARK: - STATE
public struct MapState: Equatable {
    var text: String = "Hello World ToPwr"
    public init(){}
}
//MARK: - ACTION
public enum MapAction: Equatable {
    case buttonTapped
}

//MARK: - ENVIRONMENT
public struct MapEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let mapReducer = Reducer<
    MapState,
    MapAction,
    MapEnvironment
> { state, action, environment in
  switch action {
  case .buttonTapped:
    return .none
  }
}

//MARK: - VIEW
public struct MapView: View {
    let store: Store<MapState, MapAction>
    
    public init(
        store: Store<MapState, MapAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Text("MenuView")
            }
        }
    }
}

#if DEBUG
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(
            store: Store(
                initialState: .init(),
                reducer: mapReducer,
                environment: .init(mainQueue: .immediate)
            )
        )
    }
}
#endif
