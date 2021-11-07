import SwiftUI
import ComposableArchitecture
import CoreMedia
import Strings

//MARK: - STATE
public struct ScienceClubListState: Equatable {
    let title: Text = Strings.ScienceClubList.title
    var scienceClubs: IdentifiedArrayOf<ScienceClubCellState> = []
    
    var isLoading: Bool {
        scienceClubs.isEmpty ? true : false
    }
    
    public init(){
        #warning("MOCKS! TODO: API CONNECT")
        self.scienceClubs = [
            .mocks(id: 1),
            .mocks(id: 2),
            .mocks(id: 3),
            .mocks(id: 4),
            .mocks(id: 5)
        ]
    }
}

//MARK: - ACTION
public enum ScienceClubListAction: Equatable {
    case buttonTapped
    case cellAction(id: ScienceClubCellState.ID, action: ScienceClubCellAction)
}

//MARK: - ENVIRONMENT
public struct ScienceClubListEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let scienceClubListReducer = Reducer<
    ScienceClubListState,
    ScienceClubListAction,
    ScienceClubListEnvironment
>
    .combine(
        scienceClubCellReducer.forEach(
            state: \.scienceClubs,
            action: /ScienceClubListAction.cellAction(id:action:),
            environment: { env in
                    .init(mainQueue: env.mainQueue)
            }
        ),
        Reducer{ state, action, environment in
            switch action {
            case .buttonTapped:
                print("CELL TAPPED")
                return .none
            case .cellAction:
                return .none
            }
        }
    )

//MARK: - VIEW
public struct ScienceClubListView: View {
    let store: Store<ScienceClubListState, ScienceClubListAction>
    
    public init(
        store: Store<ScienceClubListState, ScienceClubListAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            HStack() {
                viewStore.title
                    .bold()
                Spacer()
            }
            .padding(.trailing)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack() {
                    ForEachStore(
                        self.store.scope(
                            state: \.scienceClubs,
                            action: ScienceClubListAction.cellAction(id:action:)
                        )
                    ) { store in
                        ScienceClubCellView(store: store)
                    }
                }
            }
            .padding(.bottom, 30)
        }
    }
}
