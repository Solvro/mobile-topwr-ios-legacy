import SwiftUI
import ComposableArchitecture
import Combine
import Common

//MARK: - STATE
public struct InfoListState: Equatable {
    var infos: IdentifiedArrayOf<InfoDetailsState> = .init(uniqueElements: [])
    var filtered: IdentifiedArrayOf<InfoDetailsState> = .init(uniqueElements: [])
    var selection: Identified<InfoDetailsState.ID, InfoDetailsState?>?

    var searchState = SearchState()
    var text: String = ""
    var isFetching = false
    var noMoreFetches = false

    
    var isLoading: Bool {
        infos.isEmpty ? true : false
    }
    
    public init(
        infos: [Info] = []
    ) {
        self.infos = .init(
            uniqueElements: infos.map {
                InfoDetailsState(info: $0)
            }
        )
        self.filtered = self.infos
    }
}

//MARK: - ACTION
public enum InfoListAction: Equatable {
    case onAppear
    case searchAction(SearchAction)
    case setNavigation(selection: UUID?)
    case infoDetailsAction(InfoDetailsAction)
    
    case fetchingOn
    case receivedInfos(Result<[Info], ErrorModel>)
    case loadMoreInfos

}

//MARK: - ENVIRONMENT
public struct InfoListEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getInfos: (Int) -> AnyPublisher<[Info], ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getInfos: @escaping (Int) -> AnyPublisher<[Info], ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getInfos = getInfos
    }
}
//MARK: - REDUCER
public let InfoListReducer =
infoDetailsReducer
.optional()
.pullback(state: \Identified.value, action: .self, environment: { $0 })
.optional()
.pullback(
  state: \InfoListState.selection,
  action: /InfoListAction.infoDetailsAction,
  environment: {
      InfoDetailsEnvironment(
        mainQueue: $0.mainQueue
      )
  }
)
.combined(
    with: Reducer<
    InfoListState,
    InfoListAction,
    InfoListEnvironment
    > { state, action, env in
        switch action {
        case .onAppear:
            return .none
        case .searchAction(.update(let text)):
            state.text = text
            
            if text.count == 0 {
                state.filtered = state.infos
            } else {
                state.filtered = .init(
                    uniqueElements: state.infos.filter {
                        $0.info.title.contains(text) ||
                        $0.info.description?.contains(text) ?? false
                    }
                )
            }
            return .none
        case .searchAction:
            return .none
        case let .setNavigation(selection: .some(id)):
            state.selection = Identified(nil, id: id)
            guard let id = state.selection?.id,
              let info = state.filtered[id: id] else { return .none }
              state.selection?.value = info
            return .none
        case .setNavigation(selection: .none):
            state.selection = nil
            return .none
        case .infoDetailsAction:
            return .none
        case .fetchingOn:
            state.isFetching = true
            return .none
            
        case .receivedInfos(.success(let infos)):
            if infos.isEmpty {
                state.noMoreFetches = true
                state.isFetching = false
                return .none
            }
            infos.forEach { info in
                state.infos.append(InfoDetailsState(info: info))
            }
            state.filtered = state.infos
            state.isFetching = false
            return .none
        case .receivedInfos(.failure(_)):
            return .none
        case .loadMoreInfos:
            return env.getInfos(state.infos.count)
                .receive(on: env.mainQueue)
                .catchToEffect()
                .map(InfoListAction.receivedInfos)
        }
    }
)
//MARK: - VIEW
public struct InfoListView: View {
    let store: Store<InfoListState, InfoListAction>
    
    public init(
        store: Store<InfoListState, InfoListAction>
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
                                action: InfoListAction.searchAction
                            )
                        ).padding(.bottom, 16)
                        LazyVStack(spacing: 16) {
                            ForEach(viewStore.filtered) { club in
                                NavigationLink(
                                    destination: IfLetStore(
                                        self.store.scope(
                                            state: \.selection?.value,
                                            action: InfoListAction.infoDetailsAction
                                        ),
                                        then: InfoDetailsView.init(store:),
                                        else: ProgressView.init
                                    ),
                                    tag: club.id,
                                    selection: viewStore.binding(
                                        get: \.selection?.id,
                                        send: InfoListAction.setNavigation(selection:)
                                    )
                                ) {
                                    InfoCellView(viewState: club)
                                        .onAppear {
                                            if !viewStore.noMoreFetches {
                                                viewStore.send(.fetchingOn)
                                                if club.id == viewStore.infos.last?.id {
                                                    viewStore.send(.loadMoreInfos)
                                                }
                                            }
                                        }

                                }
                            }
                            if viewStore.isFetching { ProgressView() }
                        }
                    }
                }
                .barLogo()
                .navigationTitle(Strings.HomeLists.infosListTitle)
            }
        }
    }
}
