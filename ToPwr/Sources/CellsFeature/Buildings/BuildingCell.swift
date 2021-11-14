import SwiftUI
import ComposableArchitecture
import Common

//MARK: - STATE
public struct BuildingCellState: Equatable, Identifiable {
    public let id: Int
    let building: Map
    
    public init(
        building: Map
    ) {
        self.id = building.id
        self.building = building
    }
}
//MARK: - ACTION
public enum BuildingCellAction: Equatable {
    case buttonTapped
}

//MARK: - ENVIRONMENT
public struct BuildingCellEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let buildingCellReducer = Reducer<
    BuildingCellState,
    BuildingCellAction,
    BuildingCellEnvironment
> { state, action, environment in
  switch action {
  case .buttonTapped:
      print("Building Button Tapped")
    return .none
  }
}

//MARK: - VIEW
public struct BuildingCellView: View {
    let store: Store<BuildingCellState, BuildingCellAction>
    
    public init(
        store: Store<BuildingCellState, BuildingCellAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            Button(action: {
                viewStore.send(.buttonTapped)
            }, label: {
                ZStack(alignment: .bottomLeading) {
                    ImageView(
                        url: URL(string: viewStore.building.photo?.url ?? ""),
                        contentMode: .aspectFill
                    )
                        .frame(width: 120, height: 120)
                        .cornerRadius(8)

                    Text(viewStore.building.code ?? "")
                        .font(.appBoldTitle2)
                        .foregroundColor(.white)
                        .padding()
                }
            })
        }
    }
}

//MARK: - MOCKS & PREVIEW
#if DEBUG
public extension BuildingCellState {
    static let mock: Self = .init(
        building: .mock
    )
}
#endif