import SwiftUI
import ComposableArchitecture
import Common
import Combine
import HomeFeature

//MARK: - STATE
public struct MapFeatureState: Equatable {
	var mapBottomSheetState = MapBottomSheetState()
	var mapViewState = MapState(id: UUID(), annotations: [])
	var isOpen: Bool = false
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
	case mapViewAction(MapAction)
	case sheetOpenStatusChanged(Bool)
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
		state.mapViewState = MapState(
			id: UUID(),
			annotations: buildings.map({ value in
				CustomAnnotation(
					coordinate: .init(
						latitude: value.latitude!,
						longitude: value.longitude!
					),
					title: value.code
				)
			})
		)
		return .none
	case .receivedBuildings(.failure(let error)):
#warning("TODO: Show couldn't low data message")
		return .none
	case .buildingListAction(.configureToSelectedAnnotationAcion(let title)):
		return .none
	case .buttonTapped:
		return .none
	case .mapAction(_):
		return .none
	case .mapViewAction(.annotationTapped(let annotation)):
		if let title = annotation?.title {
			return .merge (
				Effect(value: .buildingListAction(.configureToSelectedAnnotationAcion(title))),
				Effect(value: .sheetOpenStatusChanged(true))
			)
		}	else {
			return .merge(
				Effect(value: .buildingListAction(.searchAction(.update("")))),
				Effect(value: .sheetOpenStatusChanged(false))
			)
		}
	case .mapViewAction(.binding(_)):
		return .none
	case .buildingListAction(.searchAction(_)):
		return .none
	case .buildingListAction(.cellAction(id: let id, action: .buttonTapped)):
		let buildingState = state.mapBottomSheetState.buildings.first(where: { cellState in cellState.building.id == id})
		if let buildingState = buildingState,
		   let code = buildingState.building.code,
		   let lat = buildingState.building.latitude,
		   let lon = buildingState.building.longitude {
			return .merge(
			Effect(value:
					.mapViewAction(
						.annotationTapped(
							CustomAnnotation(
								coordinate: .init(
									latitude: lat,
									longitude: lon
								),
								title: code
							)
						)
					)
			),
			Effect(value: .mapAction(.searchAction(.update(code)))),
			Effect(value: .mapViewAction(.speciaUseNewselectionSetter(true)))
			)
		}	else {
			return .none
		}
	case .sheetOpenStatusChanged(let status):
		state.isOpen = status
		return .none
	case .mapViewAction(.speciaUseNewselectionSetter(_)):
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
).combined(
	with: mapReducer
		.pullback(
			state: \.mapViewState,
			action: /MapFeatureAction.mapViewAction,
			environment: { env in
				MapEnvironment(mainQueue: env.mainQueue)
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
			ZStack {
				MapViewWrapper(
					store: store.scope(
						state: \.mapViewState,
						action: MapFeatureAction.mapViewAction
					)
				)
				MapBottomSheetView(
					maxHeight: UIScreen.main.bounds.height * 0.7,
					store: self.store.scope(
						state: \.mapBottomSheetState,
						action: MapFeatureAction.buildingListAction
					),
					isOpen: Binding(
						get: { viewStore.isOpen },
						set: { viewStore.send(.sheetOpenStatusChanged($0)) }
					)
				)
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
				environment: .init(
					getBuildings: failing0,
					mainQueue: .immediate
				)
			)
		)
	}
}
#endif

