import SwiftUI
import ComposableArchitecture
import Combine
import Common

//MARK: - STATE
public struct ClubListState: Equatable {
    var clubs: IdentifiedArrayOf<ClubDetailsState> = .init(uniqueElements: [])
    var filtered: IdentifiedArrayOf<ClubDetailsState> = .init(uniqueElements: [])
    var fetchedClubs: IdentifiedArrayOf<ClubDetailsState> = .init(uniqueElements: [])
    var selection: Identified<ClubDetailsState.ID, ClubDetailsState?>?
    
    var searchState = SearchState()
    var text: String = ""
    var defaultFetchingValue = 2
    var isFetching = false
    
    var isLoading: Bool {
        clubs.isEmpty ? true : false
    }
    
    public init(
        clubs: [ScienceClub] = []
    ) {
        self.clubs = .init(
            uniqueElements: clubs.map {
                ClubDetailsState(club: $0)
            }
        )
        self.filtered = self.clubs
        guard self.clubs.count >= defaultFetchingValue else { self.fetchedClubs = self.clubs; return }
        for item in 0..<defaultFetchingValue {
            self.fetchedClubs.append(self.clubs[item])
        }
    }
}

//MARK: - ACTION
public enum ClubListAction: Equatable {
    case listButtonTapped
    case appendToFetchingTable
    case toogleFetchingState
    case searchAction(SearchAction)
    case setNavigation(selection: UUID?)
    case clubDetailsAction(ClubDetailsAction)
}

//MARK: - ENVIRONMENT
public struct ClubListEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getDepartment: (Int) -> AnyPublisher<Department, ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getDepartment: @escaping (Int) -> AnyPublisher<Department, ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getDepartment = getDepartment
    }
}
//MARK: - REDUCER
public let clubListReducer =
clubDetailsReducer
    .optional()
    .pullback(state: \Identified.value, action: .self, environment: { $0 })
    .optional()
    .pullback(
        state: \ClubListState.selection,
        action: /ClubListAction.clubDetailsAction,
        environment: {
            ClubDetailsEnvironment(
                mainQueue: $0.mainQueue,
                getDepartment: $0.getDepartment
            )
        }
    )
    .combined(
        with: Reducer<
        ClubListState,
        ClubListAction,
        ClubListEnvironment
        > { state, action, env in
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
            case let .setNavigation(selection: .some(id)):
                state.selection = Identified(nil, id: id)
                guard let id = state.selection?.id,
                      let club = state.filtered[id: id] else { return .none }
                state.selection?.value = club
                return .none
            case .setNavigation(selection: .none):
                state.selection = nil
                return .none
            case .clubDetailsAction:
                return .none
            case .appendToFetchingTable:
                let lowerValue = state.fetchedClubs.count
                var higherValue = lowerValue + state.defaultFetchingValue
                // When there is less number of elements available to fetch then [defaultFetchingValue]:
                // in that case we need to fetch everything what is left
                if state.clubs.count < lowerValue + state.defaultFetchingValue {
                    higherValue = state.clubs.count
                }
                for item in lowerValue..<higherValue { state.fetchedClubs.append(state.clubs[item]) }
                return .none
            case .toogleFetchingState:
                state.isFetching.toggle()
                return .none
            }
        }
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
                        ).padding(.bottom, 16)
                        LazyVStack(spacing: 16) {
                            ForEach(viewStore.fetchedClubs) { club in
                                NavigationLink(
                                    destination: IfLetStore(
                                        self.store.scope(
                                            state: \.selection?.value,
                                            action: ClubListAction.clubDetailsAction
                                        ),
                                        then: ClubDetailsView.init(store:),
                                        else: ProgressView.init
                                    ),
                                    tag: club.id,
                                    selection: viewStore.binding(
                                        get: \.selection?.id,
                                        send: ClubListAction.setNavigation(selection:)
                                    )
                                ) {
                                    ClubCellView(viewState: club)
                                        .onAppear {
                                            if viewStore.fetchedClubs.last?.id == club.id && viewStore.fetchedClubs.count != viewStore.clubs.count {
                                                viewStore.send(.toogleFetchingState)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
                                                    viewStore.send(.appendToFetchingTable)
                                                    viewStore.send(.toogleFetchingState)
                                                    print("# Fake fetching new data rows ⌛️")
                                                }
                                            }
                                        }
                                }
                            }
                        }
                        if viewStore.isFetching { ProgressView() }
                    }
                }
                .barLogo()
                .navigationTitle(Strings.HomeLists.scienceClubsTitle)
            }
        }
    }
}
