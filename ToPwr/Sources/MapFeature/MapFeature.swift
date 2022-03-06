import SwiftUI
import ComposableArchitecture
import Common
import Combine
import HomeFeature

//MARK: - STATE
public struct MapFeatureState: Equatable {
    var mapBottomSheetState = MapBottomSheetState()
    public init(){}
}

//MARK: - ACTION
public enum MapFeatureAction: Equatable {
    case onAppear
    case buttonTapped
    case mapAction(MapBottomSheetAction)
    case loadApiData
    case loadBuildings
    case receivedBuildings(Result<[Map], ErrorModel>)
    case buildingListAction(MapBottomSheetAction)
}

//MARK: - ENVIRONMENT
public struct MapFeatureEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var getBuildings: () -> AnyPublisher<[Map], ErrorModel>
    
    public init (
        getBuildings: @escaping () -> AnyPublisher<[Map], ErrorModel>,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
        self.getBuildings = getBuildings
    }
}

//MARK: - REDUCER
public let mapFeatureReducer = Reducer<
    MapFeatureState,
    MapFeatureAction,
    MapFeatureEnvironment
> { state, action, env in
  switch action {
  case .onAppear:
      return .init(value: .loadApiData)
  case .loadApiData:
      return .init(value: .loadBuildings)
  case .loadBuildings:
      return env.getBuildings()
          .receive(on: env.mainQueue)
          .catchToEffect()
          .map(MapFeatureAction.receivedBuildings)
  case .receivedBuildings(.success(let buildings)):
      state.mapBottomSheetState = .init(
        buildings: buildings.map {
            MapBuildingCellState(building: $0)
        }
      )
      return .none
  case .receivedBuildings(.failure(let error)):
      return .none
  case .buildingListAction(_):
      return .none
  case .buttonTapped:
    return .none
  case .mapAction(_):
      return .none
  }
}
.combined(
    with: mapBottomSheetReducer
        .pullback(
            state: \.mapBottomSheetState,
            action: /MapFeatureAction.buildingListAction,
            environment: { env in
                    .init(mainQueue: env.mainQueue)
            }
        )
)

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
            GeometryReader { geometry in
                MapView()
                MapBottomSheetView(maxHeight: geometry.size.height * 0.8,
                                   store: self.store.scope(
                                    state: \.mapBottomSheetState,
                                    action: MapFeatureAction.buildingListAction
                                   ))
            }
            .ignoresSafeArea(.keyboard)
            .edgesIgnoringSafeArea(.top)
            .onAppear {
                viewStore.send(.onAppear)
            }
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
                environment: .init(getBuildings: failing0,
                                   mainQueue: .immediate)
            )
        )
    }
}
#endif

