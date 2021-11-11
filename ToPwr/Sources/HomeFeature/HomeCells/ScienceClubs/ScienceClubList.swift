import SwiftUI
import ComposableArchitecture
import CoreMedia
import Common

//MARK: - STATE
public struct ScienceClubListState: Equatable {
    let title: String = "Koła naukowe"
    var scienceClubs: IdentifiedArrayOf<ScienceClubCellState>
    
    var isLoading: Bool {
        scienceClubs.isEmpty ? true : false
    }
    
    public init(
        scienceClubs: [ScienceClubCellState] = []
    ){
        self.scienceClubs = .init(uniqueElements: scienceClubs)
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
            HStack {
                Text(viewStore.title)
                    .font(.appBoldTitle1)
                Spacer()
            }
            .padding()
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
                .padding(.leading, 10)
            }
            .padding(.bottom, 30)
        }
    }
}
