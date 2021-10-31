import SwiftUI
import ComposableArchitecture

//MARK: - STATE
public struct BuildingListState: Equatable {
    let title: String = "Ostatnio wyszukiwane"
    let buttonText: String = "Lista"
    var buildings: IdentifiedArrayOf<BuildingCellState> = []
    
    var isLoading: Bool {
        buildings.isEmpty ? true : false
    }
    
    public init(){
        #warning("MOCKS! TODO: API CONNECT")
        self.buildings = [
            .mocks(id: 1),
            .mocks(id: 2),
            .mocks(id: 3),
            .mocks(id: 4),
            .mocks(id: 5)
        ]
    }
}
//MARK: - ACTION
public enum BuildingListAction: Equatable {
    case buttonTapped
    case listButtonTapped
    case cellAction(id: BuildingCellState.ID, action: BuildingCellAction)
}

//MARK: - ENVIRONMENT
public struct BuildingListEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let buildingListReducer = Reducer<
    BuildingListState,
    BuildingListAction,
    BuildingListEnvironment
>
    .combine(
        buildingCellReducer.forEach(
            state: \.buildings,
            action: /BuildingListAction.cellAction(id:action:),
            environment: { env in
                    .init(mainQueue: env.mainQueue)
            }
        ),
        Reducer{ state, action, environment in
            switch action {
            case .buttonTapped:
                print("CELL TAPPED")
                return .none
            case .listButtonTapped:
                return .none
            case .cellAction:
                return .none
            }
        }
    )

//MARK: - VIEW
public struct BuildingListView: View {
    let store: Store<BuildingListState, BuildingListAction>
    
    public init(
        store: Store<BuildingListState, BuildingListAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            
            HStack() {
                Text("Ostatnio wyszukiwane")
                    .bold()
                Spacer()
                Text("Mapa")
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.trailing)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEachStore(
                        self.store.scope(
                            state: \.buildings,
                            action: BuildingListAction.cellAction(id:action:)
                        )
                    ) { store in
                        BuildingCellView(store: store)
                    }
                }
            }
            .padding(.bottom, 30)
        }
    }
}
