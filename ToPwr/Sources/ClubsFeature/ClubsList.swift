import SwiftUI
import ComposableArchitecture
import Common
import Strings

//MARK: - STATE
public struct ClubListState: Equatable {
    var clubs: IdentifiedArrayOf<ClubCellState>
    var filtered: IdentifiedArrayOf<ClubCellState>
    var searchState = SearchState()
    var text: String = ""
    
    var isLoading: Bool {
        clubs.isEmpty ? true : false
    }
    
    public init(
        clubs: [ClubCellState] = []
    ) {
        self.clubs = .init(uniqueElements: clubs)
        self.filtered = self.clubs
    }
}

//MARK: - ACTION
public enum ClubListAction: Equatable {
    case listButtonTapped
    case searchAction(SearchAction)
    case cellAction(id: ClubCellState.ID, action: ClubCellAction)
}

//MARK: - ENVIRONMENT
public struct ClubListEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}
//MARK: - REDUCER
public let clubListReducer = Reducer<
    ClubListState,
    ClubListAction,
    ClubListEnvironment
>
    .combine(
        ClubCellReducer.forEach(
            state: \.clubs,
            action: /ClubListAction.cellAction(id:action:),
            environment: { env in
                    .init(mainQueue: env.mainQueue)
            }
        ),
        Reducer{ state, action, environment in
            switch action {
            case .listButtonTapped:
                return .none
            case .searchAction(.update(let text)):
                state.text = text
                
                if text.count == 0 {
                    state.filtered = state.clubs
                } else {
                    state.filtered = .init(
                        uniqueElements: state.clubs.filter {
                            $0.club.name?.contains(text) ?? false ||
                            $0.club.description?.contains(text) ?? false
                        }
                    )
                }
                return .none
            case .searchAction:
                return .none
            case .cellAction:
                return .none
            }
        }
    )
    .combined(
        with: searchReducer
            .pullback(
                state: \.searchState,
                action: /ClubListAction.searchAction,
                environment: { env in
                        .init(mainQueue: env.mainQueue)
                }
            )
    )
//MARK: - VIEW
public struct ClubListView: View {
    let store: Store<ClubListState, ClubListAction>
    
    public init(
        store: Store<ClubListState, ClubListAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        SearchView(
                            store: self.store.scope(
                                state: \.searchState,
                                action: ClubListAction.searchAction
                            )
                        )
                        
                        LazyVStack(spacing: 10) {
                            ForEachStore(
                                self.store.scope(
                                    state: \.filtered,
                                    action: ClubListAction.cellAction(id:action:)
                                )
                            ) { store in
                                ClubCellView(store: store)
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(
                        placement: .navigationBarLeading
                    ) {
                        HStack {
                            LogoView()
                                .aspectRatio(contentMode: .fit)
                            Spacer()
                        }
                        .frame(height: 20)
                        .padding([.bottom, .top], 10)
                    }
                }
                .navigationTitle(Strings.ScienceClubList.title)
            }
        }
    }
}
