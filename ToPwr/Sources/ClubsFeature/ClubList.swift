import SwiftUI
import ComposableArchitecture
import Combine
import Common

public struct ClubList: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        var clubs: IdentifiedArrayOf<ClubDetails.State> = .init(uniqueElements: [])
        var filtered: IdentifiedArrayOf<ClubDetails.State> = .init(uniqueElements: [])
        var selection: ClubDetails.State?
        
        // FIXME: - What placehodler?
        var searchState = SearchFeature.State(placeholder: "")
        var clubTagsState = ClubTagFilter.State()
        
        var text: String = ""
        var tag: Tag? = nil
        
        var isFetching = false
        var fetchedAll = false
        var noMoreFetches = false
        
        public init(clubs: [ScienceClub] = []) {
            self.clubs = .init(
                uniqueElements: clubs.map {
                    ClubDetails.State(club: $0)
                }
            )
            self.filtered = self.clubs
        }
    }
    
    // MARK: - Action
    public enum Action: Equatable {
        case listButtonTapped
        case fetchingOn
        case updateFiltered
        case searchAction(SearchFeature.Action)
        case clubTags(ClubTagFilter.Action)
        case setNavigation(selection: UUID?)
        case clubDetailsAction(ClubDetails.Action)
        case receivedClubs(Result<[ScienceClub], ErrorModel>)
        case receiveAllClubs(Result<[ScienceClub], ErrorModel>)
        case loadMoreClubs
        case loadAllClubs
    }
    
    // MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .listButtonTapped:
                return .none
            case .updateFiltered:
                if state.text.count == 0 && state.tag == nil {
                    state.filtered = state.clubs
                }
                else if state.text.count != 0 && state.tag == nil {
                    state.filtered = .init(
                        uniqueElements: state.clubs.filter {
                            $0.club.name?.contains(state.text) ?? false ||
                            $0.club.description?.contains(state.text) ?? false
                        }
                    )
                }
                else if state.text.count == 0 && state.tag != nil {
                    state.filtered = .init(
                        uniqueElements: state.clubs.filter {
                            $0.club.tags.contains(state.tag!)
                        }
                    )
                }
                else if state.text.count != 0 && state.tag != nil {
                    state.filtered = .init(
                        uniqueElements: state.clubs.filter {
                            $0.club.name?.contains(state.text) ?? false ||
                            $0.club.description?.contains(state.text) ?? false
                        }
                    )
                    state.filtered = .init(
                        uniqueElements: state.filtered.filter {
                            $0.club.tags.contains(state.tag!)
                        }
                    )
                }
                return .none
            case .searchAction(.update(let text)):
                state.text = text
                return .init(value: .updateFiltered)
            case .searchAction:
                return .none
            case .clubTags(.updateFilter(let tag)):
                state.tag = tag
                if state.fetchedAll {
                    return .init(value: .updateFiltered)
                } else {
                    return .init(value: .loadAllClubs)
                }
            case .clubTags:
                return .none
            case let .setNavigation(selection: .some(id)):
//                state.selection = Identified(nil, id: id)
//                guard let id = state.selection?.id,
//                      let club = state.filtered[id: id] else { return .none }
//                state.selection?.value = club
                // TODO: - Correctly handle navigation
                return .none
            case .setNavigation(selection: .none):
                state.selection = nil
                return .none
            case .clubDetailsAction:
                return .none
            case .loadMoreClubs:
//                return env.getClubs(state.clubs.count)
//                    .receive(on: env.mainQueue)
//                    .catchToEffect()
//                    .map(ClubListAction.receivedClubs)
                return .none
            case .receivedClubs(.success(let clubs)):
                if clubs.isEmpty {
                    state.noMoreFetches = true
                    state.isFetching = false
                    state.fetchedAll = true
                    return .none
                }
                clubs.forEach {
                    state.clubs.append(ClubDetails.State(club: $0))
                }
                state.filtered = state.clubs
                state.isFetching = false
                let tags: [Tag] = state.clubs.flatMap {
                    $0.club.tags
                }
                return .init(value: .clubTags(.updateTags(tags)))
            case .receivedClubs(.failure(_)):
                return .none
            case .fetchingOn:
                state.isFetching = true
                return .none
            case .loadAllClubs:
//                return env.getAllClubs()
//                    .receive(on: env.mainQueue)
//                    .catchToEffect()
//                    .map(ClubListAction.receiveAllClubs)
                return .none
            case .receiveAllClubs(.success(let clubs)):
                state.clubs = IdentifiedArrayOf<ClubDetails.State>.init(uniqueElements: clubs.compactMap { ClubDetails.State(club: $0)})
                state.filtered = state.clubs
                state.isFetching = false
                state.fetchedAll = true
                state.noMoreFetches = true
                return .init(value: .updateFiltered)
            case .receiveAllClubs(.failure(let error)):
                return .none
            }
        }
        .ifLet(
            \.selection,
             action: /Action.clubDetailsAction
        ) {
            ClubDetails()
        }
        // some for each here
    }
}

//MARK: - VIEW
public struct ClubListView: View {
    let store: StoreOf<ClubList>
    
    public init(store: StoreOf<ClubList>) {
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
                                action: ClubList.Action.searchAction
                            )
                        )
                        .padding(.bottom, 16)
                        
                        ClubTagFilterView(
                            store: self.store.scope(
                                state: \.clubTagsState,
                                action: ClubList.Action.clubTags
                            )
                        )
                        
                        LazyVStack(spacing: 16) {
                            ForEach(viewStore.filtered) { club in
                                // TODO: - Implement
//                                NavigationLink(
//                                    destination: IfLetStore(
//                                        self.store.scope(
//                                            state: \.selection?.value,
//                                            action: ClubList.Action.clubDetailsAction
//                                        ),
//                                        then: ClubDetailsView.init(store:),
//                                        else: ProgressView.init
//                                    ),
//                                    tag: club.id,
//                                    selection: viewStore.binding(
//                                        get: \.selection?.id,
//                                        send: ClubList.Action.setNavigation(selection:)
//                                    )
//                                ) {

//                                }
                                
                                ClubCellView(viewState: club)
                                    .onAppear {
                                        if !viewStore.noMoreFetches{
                                            viewStore.send(.fetchingOn)
                                            if club.id == viewStore.clubs.last?.id {
                                                viewStore.send(.loadMoreClubs)
                                            }
                                        }
                                    }
                            }
                            if viewStore.isFetching { ProgressView() }
                        }
                        .padding(.bottom, UIDimensions.normal.size)
                    }
                }
                .barLogo()
                .navigationTitle(Strings.HomeLists.scienceClubsTitle)
            }
        }
    }
}

#if DEBUG
// MARK: - Mock
extension ClubList.State {
    static let mock: Self = .init()
}

// MARK: - Preview
private struct ClubListView_Preview: PreviewProvider {
    static var previews: some View {
        ClubListView(
            store: .init(
                initialState: .mock,
                reducer: ClubList()
            )
        )
    }
}

#endif
