//import SwiftUI
//import ComposableArchitecture
//import Common
//import Combine
//import HomeFeature
//
////MARK: - STATE
//public struct MapFeatureState: Equatable {
//	var mapBottomSheetState = MapBottomSheetState()
//	var mapViewState = MapState(id: UUID(), annotations: [])
//	public var isOpen: Bool = false
//	var isFullView: Bool = true
//	var selectionFromList: Bool = false
//	public let bottomSheetOnAppearUpSlideDelay = 0.5
//	var preselectionID: Int?
//	var showAlert = false
//	
//	public init(preselectionID: Int? = nil){
//		self.preselectionID = preselectionID
//	}
//}
//
////MARK: - ACTION
//public enum MapFeatureAction: Equatable {
//	case onAppear
//	case buttonTapped
//	case mapAction(MapBottomSheetAction)
//	case loadApiData
//	case loadBuildings
//	case receivedBuildings(Result<[Map], ErrorModel>)
//	case buildingListAction(MapBottomSheetAction)
//	case mapViewAction(MapAction)
//	case sheetOpenStatusChanged(Bool)
//	case fullViewChangeRequest(Bool)
//	case showAlertStateChange(Bool)
//}
//
////MARK: - ENVIRONMENT
//public struct MapFeatureEnvironment {
//	var mainQueue: AnySchedulerOf<DispatchQueue>
//	var getBuildings: () -> AnyPublisher<[Map], ErrorModel>
//	
//	public init (
//		getBuildings: @escaping () -> AnyPublisher<[Map], ErrorModel>,
//		mainQueue: AnySchedulerOf<DispatchQueue>
//	) {
//		self.mainQueue = mainQueue
//		self.getBuildings = getBuildings
//	}
//}
//
////MARK: - REDUCER
//public let mapFeatureReducer = Reducer<
//	MapFeatureState,
//	MapFeatureAction,
//	MapFeatureEnvironment
//> { state, action, env in
//	switch action {
//	case .onAppear:
//		return .init(value: .loadApiData)
//	case .loadApiData:
//		return .init(value: .loadBuildings)
//	case .loadBuildings:
//		return env.getBuildings()
//			.receive(on: env.mainQueue)
//			.catchToEffect()
//			.map(MapFeatureAction.receivedBuildings)
//	case .receivedBuildings(.success(let buildings)):
//		state.mapBottomSheetState = .init(
//			buildings: buildings.map {
//				MapBuildingCellState(building: $0)
//			},
//			selectedId: nil
//		)
//		state.mapViewState = MapState(
//			id: UUID(),
//			annotations: buildings.map({ value in
//				CustomAnnotation(
//					coordinate: .init(
//						latitude: value.latitude!,
//						longitude: value.longitude!
//					),
//					title: value.code,
//					id: value.id
//				)
//			})
//		)
//		if let preselectedID = state.preselectionID {
//			state.preselectionID = nil
//			return .init(value: .buildingListAction(.cellAction(id: preselectedID, action: .buttonTapped)))
//		}	else {
//			return .none
//		}
//	case .receivedBuildings(.failure(let error)):
//		state.showAlert = true
//		return .none
//	case .buildingListAction(.configureToSelectedAnnotationAcion(let annotaton)):
//		return .none
//	case .buttonTapped:
//		return .none
//	case .mapAction(_):
//		return .none
//	case .mapViewAction(.annotationTapped(let annotation)):
//		if state.selectionFromList {
//			state.selectionFromList = false
//			return .none
//		}	else {
//			if let annotation = annotation {
//				return .concatenate (
//					.init(value: .buildingListAction(.forcedCellAction(id: annotation.id, action: .buttonTapped)))
//				)
//			}
//			return .none
//		}
//	case .mapViewAction(.annotationTappedInList(let annotation)):
//		return .none
//	case .buildingListAction(.searchAction(_)):
//		return .none
//	case .buildingListAction(.cellAction(id: let id, action: .buttonTapped)):
//		let buildingState = state.mapBottomSheetState.buildings.first(where: { cellState in cellState.building.id == id})
//		state.selectionFromList = true
//		if let buildingState = buildingState,
//		   let lat = buildingState.building.latitude,
//		   let lon = buildingState.building.longitude
//		{
//			return .concatenate(
//				.init(value: .mapViewAction(.speciaUseNewselectionSetter(true))),
//				.init(value:
//						.mapViewAction(
//							.annotationTappedInList(
//								CustomAnnotation(
//									coordinate: .init(
//										latitude: lat,
//										longitude: lon
//									),
//									title: buildingState.building.code,
//									id: buildingState.building.id
//								)
//							)
//						)
//				)
//			)
//		}	else {
//			return .none
//		}
//	case .sheetOpenStatusChanged(let status):
//		state.isOpen = status
//		return .none
//	case .mapViewAction(.speciaUseNewselectionSetter(_)):
//		return .none
//	case .buildingListAction(.newCellSelected(_)):
//		return .none
//	case .buildingListAction(.selectedCellAction(.buttonTapped)):
//		state.isFullView = true
//		return .none
//	case .mapViewAction(.annotationDeselected):
//		return .init(value: .buildingListAction(.selectedCellAction(.buttonTapped)))
//	case .buildingListAction(.forcedCellAction(id: let id, action: let action)):
//		return .none
//	case .fullViewChangeRequest(let isFull):
//		state.isFullView = isFull
//		return .none
//	case .buildingListAction(.remoteCancelationConf):
//		state.isFullView = false
//		return .none
//	case .showAlertStateChange(let newState):
//		state.showAlert = newState
//		return .none
//	}
//}
//.combined(
//	with: mapBottomSheetReducer
//		.pullback(
//			state: \.mapBottomSheetState,
//			action: /MapFeatureAction.buildingListAction,
//			environment: { env in
//					.init(mainQueue: env.mainQueue)
//			}
//		)
//).combined(
//	with: mapReducer
//		.pullback(
//			state: \.mapViewState,
//			action: /MapFeatureAction.mapViewAction,
//			environment: { env in
//				MapEnvironment(mainQueue: env.mainQueue)
//			}
//		)
//)
//
////MARK: - VIEW
//public struct MapFeatureView: View {
//	let store: Store<MapFeatureState, MapFeatureAction>
//	
//	public init(
//		store: Store<MapFeatureState, MapFeatureAction>
//	) {
//		self.store = store
//	}
//	
//	public var body: some View {
//		WithViewStore(store) { viewStore in
//			ZStack {
//				MapViewWrapper(
//					store: store.scope(
//						state: \.mapViewState,
//						action: MapFeatureAction.mapViewAction
//					)
//				)
//				MapBottomSheetView(
//					maxHeight: UIScreen.main.bounds.height * 0.7,
//					store: self.store.scope(
//						state: \.mapBottomSheetState,
//						action: MapFeatureAction.buildingListAction
//					),
//					isOpen: Binding(
//						get: { viewStore.isOpen },
//						set: { viewStore.send(.sheetOpenStatusChanged($0)) }
//					),
//					isFullView: Binding(
//						get: { viewStore.isFullView },
//						set: { viewStore.send(.fullViewChangeRequest($0)) }
//					)
//				)
//			}
//			.alert(isPresented: Binding(
//				get: { viewStore.showAlert },
//				set: { viewStore.send(.showAlertStateChange($0)) }
//			)) {
//				Alert(
//					title: Text(Strings.Other.networkError),
//					primaryButton: .default(
//						Text(Strings.Other.tryAgain),
//						action: {
//							viewStore.send(.loadBuildings)
//					} ),
//					secondaryButton: .cancel(Text(Strings.Other.cancel))
//				)
//			}
//			.ignoresSafeArea(.keyboard)
//			.edgesIgnoringSafeArea(.top)
//			.onAppear {
//				viewStore.send(.onAppear)
//			}
//		}
//	}
//}
//
//#if DEBUG
//struct MapFeatureView_Previews: PreviewProvider {
//	static var previews: some View {
//		MapFeatureView(
//			store: Store(
//				initialState: .init(),
//				reducer: mapFeatureReducer,
//				environment: .init(
//					getBuildings: failing0,
//					mainQueue: .immediate
//				)
//			)
//		)
//	}
//}
//#endif
//
