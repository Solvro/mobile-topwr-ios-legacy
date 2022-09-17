import SwiftUI
import ComposableArchitecture
import Combine
import Common

//MARK: - STATE
public struct ClubHomeListState: Equatable {
    let title: String = Strings.HomeLists.scienceClubsTitle
    let buttonText: String = Strings.HomeLists.departmentListButton
    
    var clubs: IdentifiedArrayOf<ClubDetailsState> = .init(uniqueElements: [])
    var selection: Identified<ClubDetailsState.ID, ClubDetailsState?>?
    
    var isLoading: Bool {
        clubs.isEmpty ? true : false
    }
    var isFetching = false
    var noMoreFetches = false
    
    public init(
        clubs: [ClubDetailsState] = []
    ){
        self.clubs = .init(uniqueElements: clubs)
    }
}

//MARK: - ACTION
public enum ClubHomeListAction: Equatable {
    case listButtonTapped
    case setNavigation(selection: UUID?)
    case clubDetailsAction(ClubDetailsAction)
    case receivedClubs(Result<[ScienceClub], ErrorModel>)
    case loadMoreClubs
    case fetchingOn
}

//MARK: - ENVIRONMENT
public struct ClubHomeListEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getDepartment: (Int) -> AnyPublisher<Department, ErrorModel>
    let getClubs: (Int) -> AnyPublisher<[ScienceClub], ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getDepartment: @escaping (Int) -> AnyPublisher<Department, ErrorModel>,
        getClubs: @escaping (Int) -> AnyPublisher<[ScienceClub], ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getDepartment = getDepartment
        self.getClubs = getClubs
    }
}

//MARK: - REDUCER
public let clubHomeListReducer =
clubDetailsReducer
.optional()
.pullback(state: \Identified.value, action: .self, environment: { $0 })
.optional()
.pullback(
  state: \ClubHomeListState.selection,
  action: /ClubHomeListAction.clubDetailsAction,
  environment: {
      ClubDetailsEnvironment(
        mainQueue: $0.mainQueue,
        getDepartment: $0.getDepartment
      )
  }
)
.combined(
    with: Reducer<
    ClubHomeListState,
    ClubHomeListAction,
    ClubHomeListEnvironment
    > { state, action, env in
        switch action {
        case .listButtonTapped:
            return .none
        case let .setNavigation(selection: .some(id)):
            state.selection = Identified(nil, id: id)
            guard let id = state.selection?.id,
                  let club = state.clubs[id: id] else { return .none }
            state.selection?.value = club
            return .none
        case .setNavigation(selection: .none):
            state.selection = nil
            return .none
        case .clubDetailsAction(_):
            return .none
        case .loadMoreClubs:
            return env.getClubs(state.clubs.count)
                .receive(on: env.mainQueue)
                .catchToEffect()
                .map(ClubHomeListAction.receivedClubs)
        case .receivedClubs(.success(let clubs)):
            if clubs.isEmpty {
                state.noMoreFetches = true
                state.isFetching = false
                return .none
            }
            clubs.forEach { state.clubs.append(ClubDetailsState(club: $0)) }
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
public struct ClubHomeListView: View {
    let store: Store<ClubHomeListState, ClubHomeListAction>
    
    public init(
        store: Store<ClubHomeListState, ClubHomeListAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            HStack() {
                Text(viewStore.title)
                    .font(.appMediumTitle2)
                    .foregroundColor(K.FontColors.primary)
                Spacer()
                Button(
                    action: {
                        viewStore.send(.listButtonTapped)
                    },
                    label: {
                        Text(viewStore.buttonText)
                            .foregroundColor(K.Colors.red)
                            .font(.appRegularTitle3)
                        Image(systemName: "chevron.right")
                            .foregroundColor(K.Colors.red)
                    }
                )
            }
            .horizontalPadding(.normal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(viewStore.clubs) { club in
                        NavigationLink(
                            destination: IfLetStore(
                                self.store.scope(
                                    state: \.selection?.value,
                                    action: ClubHomeListAction.clubDetailsAction
                                ),
                                then: ClubDetailsView.init(store:),
                                else: ProgressView.init
                            ),
                            tag: club.id,
                            selection: viewStore.binding(
                                get: \.selection?.id,
                                send: ClubHomeListAction.setNavigation(selection:)
                            )
                        ) {
                            ClubHomeCellView(viewState: club)
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
                    if viewStore.isFetching { ProgressView() }
                }
                .horizontalPadding(.normal)
            }
        }
    }
}
