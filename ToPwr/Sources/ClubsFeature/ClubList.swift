import SwiftUI
import ComposableArchitecture
import Combine
import Common

//MARK: - STATE
public struct ClubListState: Equatable {
    var clubs: IdentifiedArrayOf<ClubDetailsState> = .init(uniqueElements: [])
    var filtered: IdentifiedArrayOf<ClubDetailsState> = .init(uniqueElements: [])
    var selection: Identified<ClubDetailsState.ID, ClubDetailsState?>?
    
    var searchState = SearchState()
    var text: String = ""
    var isFetching = false
    var noMoreFetches = false
    
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
    }
}

//MARK: - ACTION
public enum ClubListAction: Equatable {
    case listButtonTapped
    case fetchingOn
    case searchAction(SearchAction)
    case setNavigation(selection: UUID?)
    case clubDetailsAction(ClubDetailsAction)
    case receivedClubs(Result<[ScienceClub], ErrorModel>)
    case loadMoreClubs
}

//MARK: - ENVIRONMENT
public struct ClubListEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getDepartment: (Int) -> AnyPublisher<Department, ErrorModel>
    let getClubs: (Int) -> AnyPublisher<[ScienceClub], ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getDepartment: @escaping (Int) -> AnyPublisher<Department, ErrorModel>,
        getClubs: @escaping (Int) -> AnyPublisher<[ScienceClub], ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getClubs = getClubs
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
            case .loadMoreClubs:
                return env.getClubs(state.clubs.count)
                    .receive(on: env.mainQueue)
                    .catchToEffect()
                    .map(ClubListAction.receivedClubs)
            case .receivedClubs(.success(let clubs)):
                if clubs.isEmpty {
                    state.noMoreFetches = true
                    state.isFetching = false
                    return .none
                }
                clubs.forEach { club in
                    state.clubs.append(ClubDetailsState(club: club))
                }
                state.filtered = state.clubs
                state.isFetching = false
                return .none
            case .receivedClubs(.failure(_)):
                return .none
            case .fetchingOn:
                state.isFetching = true
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
                            ForEach(viewStore.filtered) { club in
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
                                            if !viewStore.noMoreFetches {
                                                viewStore.send(.fetchingOn)
                                                if club.id == viewStore.clubs.last?.id {
                                                    viewStore.send(.loadMoreClubs)
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
