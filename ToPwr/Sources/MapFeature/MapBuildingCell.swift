import SwiftUI
import ComposableArchitecture
import Common

//MARK: - STATE
public struct MapBuildingCellState: Equatable, Identifiable {
	public let id: Int
	public let building: Map
	
	public init(
		building: Map
	) {
		self.id = building.id
		self.building = building
	}
}
//MARK: - ACTION
public enum MapBuildingCellAction: Equatable {
	case buttonTapped
}

//MARK: - ENVIRONMENT
public struct MapBuildingCellEnvironment {
	var mainQueue: AnySchedulerOf<DispatchQueue>
	
	public init (
		mainQueue: AnySchedulerOf<DispatchQueue>
	) {
		self.mainQueue = mainQueue
	}
}

//MARK: - REDUCER
public let mapBuildingCellReducer = Reducer<
	MapBuildingCellState,
	MapBuildingCellAction,
	MapBuildingCellEnvironment
> { state, action, environment in
	switch action {
	case .buttonTapped:
		return .none
	}
}

//MARK: - VIEW
public struct MapBuildingCellView: View {
	fileprivate enum Constants {
		static let radius: CGFloat = 8
	}
	
	let store: Store<MapBuildingCellState, MapBuildingCellAction>
	
	public init(
		store: Store<MapBuildingCellState, MapBuildingCellAction>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(store) { viewStore in
			Button(action: {
				viewStore.send(.buttonTapped)
			}, label: {
				ZStack(alignment: .topLeading) {
					K.CellColors.scienceBackground
					HStack {
						VStack(alignment: .leading, spacing: 10) {
							Text("\(Strings.MapView.building + " " + (viewStore.building.code ?? ""))")
								.font(.appBoldTitle3)
								.foregroundColor(.black)
								.multilineTextAlignment(.leading)
							Text(viewStore.building.address?.address ?? "")
								.fontWeight(.light)
								.font(.system(size: 14))
								.foregroundColor(.black)
								.multilineTextAlignment(.leading)
						}.padding(.leading, UIDimensions.normal.spacing)
						Spacer()
						ZStack {
							ImageView(
								url: viewStore.building.photo?.url,
								contentMode: .aspectFill
							)
							.frame(width: 90, height: 90)
							.cornerRadius(Constants.radius, corners: [.topRight, .bottomRight])
						}
					}
				}
				.frame(height: 90)
				.foregroundColor(K.CellColors.scienceBackground)
				.cornerRadius(Constants.radius)
			}
			)
		}
	}
}

//MARK: - MOCKS & PREVIEW
#if DEBUG
public extension MapBuildingCellState {
	static let mock: Self = .init(
		building: .mock
	)
}
#endif
