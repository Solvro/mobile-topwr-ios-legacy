import SwiftUI
import ComposableArchitecture
import Common

//MARK: - STATE
public struct BuildingListState: Equatable {
    let title: String = Strings.HomeLists.buildingListTitle
    let buttonText: String = Strings.HomeLists.buildingListButton
    public var buildings: IdentifiedArrayOf<BuildingCellState> = []
    
    var isLoading: Bool {
        buildings.isEmpty ? true : false
    }
    
    public init(
        buildings: [BuildingCellState] = []
    ){
        self.buildings = .init(uniqueElements: buildings)
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
            HStack {
                Text(viewStore.title)
                    .font(.appMediumTitle2)
                    .foregroundColor(K.FontColors.primary)
                Spacer()
                Button {
                    viewStore.send(.listButtonTapped)
                } label: {
                    Text(viewStore.buttonText)
                        .foregroundColor(K.Colors.red)
                        .font(.appRegularTitle3)
                    Image(systemName: "chevron.right")
                        .foregroundColor(K.Colors.red)
                }
            }
            .horizontalPadding(.normal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 18) {
                    ForEachStore(
                        self.store.scope(
                            state: \.buildings,
                            action: BuildingListAction.cellAction(id:action:)
                        )
                    ) { store in
                        BuildingCellView(store: store)
                    }
                }
                .horizontalPadding(.normal)
            }
        }
    }
}
