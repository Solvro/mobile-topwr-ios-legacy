import SwiftUI
import ComposableArchitecture
import Combine
import Common

public struct InfoFeature: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        var listState = InfoListFeature.State()
        var showAlert = false
        var destinations = StackState<Destinations.State>()
        
        public init(){}
    }
    
    public init() {}
    
    // MARK: - Dependency
    @Dependency(\.info) var infoClient
    
    // MARK: - Action
    public enum Action: Equatable {
        case onAppear
        case loadInfos
        case loadAboutUs
        case receivedInfos(TaskResult<[Info]>)
        case receiveAboutUs(TaskResult<AboutUs>)
        case listAction(InfoListFeature.Action)
        case dismissKeyboard
        case showAlertStateChange(Bool)
        case destinations(StackAction<Destinations.State, Destinations.Action>)
    }
    
    // MARK: - Reducer
    public var body: some ReducerOf<Self> {
        
        Scope(
            state: \.listState,
            action: /Action.listAction
        ) { () -> InfoListFeature in
            InfoListFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .listAction(.navigateToAboutUs):
                if let aboutUs = state.listState.aboutUs {
                    state.destinations.append(.details(aboutUs))
                }
                return .none
            case .listAction(.navigateToDetails(let navState)):
                state.destinations.append(.details(navState))
                return .none
            case .listAction:
                return .none
            case .onAppear:
                if state.listState.infos.isEmpty {
                    return .run { send in
                        await send(.loadInfos)
                        await send(.loadAboutUs)
                    }
                }
                return .none
            case .loadInfos:
                return .task {
                    await .receivedInfos(TaskResult {
                        try await infoClient.getInfos(0)
                    })
                }
            case .receivedInfos(.success(let Infos)):
                let infos: IdentifiedArrayOf<InfoDetailsFeature.State> = .init(
                    uniqueElements: Infos.map {
                        InfoDetailsFeature.State(
                            id: $0.id,
                            url: $0.photo?.url,
                            title: $0.title,
                            description: $0.description,
                            shortDescription: $0.shortDescription,
                            infoSection: $0.infoSection
                        )
                    }
                )
                state.listState.infos = infos
                state.listState.filtered = infos
                return .none
            case .receivedInfos(.failure):
                state.showAlert = true
                return .none
            case .dismissKeyboard:
                UIApplication.shared.dismissKeyboard()
                return .none
            case .showAlertStateChange(let newState):
                state.showAlert = newState
                return .none
            case .loadAboutUs:
                return .task {
                    await .receiveAboutUs(TaskResult {
                        try await infoClient.getAboutUs()
                    })
                }
            case .receiveAboutUs(.success(let aboutUs)):
                state.listState.aboutUs = InfoDetailsFeature.State(
                    id: aboutUs.id,
                    url: aboutUs.photo?.url,
                    title: "About Us",
                    description: aboutUs.content,
                    infoSection: []
                )
                return .none
            case .receiveAboutUs(.failure):
                return .none
            case .destinations:
                return .none
            }
        }
        .forEach(\.destinations, action: /Action.destinations) {
            Destinations()
        }
    }
    
    public struct Destinations: ReducerProtocol {
        
        public enum State: Equatable {
            case details(InfoDetailsFeature.State)
        }
        
        public enum Action: Equatable {
            case details(InfoDetailsFeature.Action)
        }
        
        public var body: some ReducerProtocol<State,Action> {
            EmptyReducer()
                .ifCaseLet(
                    /State.details,
                     action: /Action.details
                ) {
                    InfoDetailsFeature()
                }
        }
    }
}

//MARK: - VIEW
public struct InfoView: View {
    let store: StoreOf<InfoFeature>
    
    public init(store: StoreOf<InfoFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStackStore(store.scope(
            state: \.destinations,
            action: InfoFeature.Action.destinations
        )) {
            WithViewStore(store, observe: { $0 }) { viewStore in
                ZStack {
                    InfoListView(
                        store: store.scope(
                            state: \.listState,
                            action: InfoFeature.Action.listAction
                        )
                    )
                }
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .alert(
                    isPresented: Binding(
                        get: { viewStore.showAlert },
                        set: { viewStore.send(.showAlertStateChange($0)) }
                    )
                ) {
                    Alert(
                        title: Text(Strings.Other.networkError),
                        primaryButton: .default(
                            Text(Strings.Other.tryAgain),
                            action: {
                                viewStore.send(.loadInfos)
                            } ),
                        secondaryButton: .cancel(Text(Strings.Other.cancel))
                    )
                }
            }
        } destination: {
            switch $0 {
            case .details:
                CaseLet(
                    /InfoFeature.Destinations.State.details,
                     action: InfoFeature.Destinations.Action.details,
                     then: InfoDetailsView.init(store:)
                )
            }
        }
    }
}

#if DEBUG
// MARK: - Mock
extension InfoFeature.State {
    static let mock: Self = .init()
}

// MARK: - Preview
private struct InfoView_Preview: PreviewProvider {
    static var previews: some View {
        InfoView(
            store: .init(
                initialState: .mock,
                reducer: InfoFeature()
            )
        )
    }
}

#endif

