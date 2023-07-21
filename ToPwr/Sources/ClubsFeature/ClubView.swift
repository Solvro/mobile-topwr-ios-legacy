import SwiftUI
import ComposableArchitecture
import Combine
import Common

public struct ClubFeature: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        var listState: ClubList.State
        var showAlert = false
        var destinations = StackState<Destinations.State>()
        
        public init(){
            self.listState = ClubList.State()
        }
    }
    
    public init() {}
    
    // MARK: - Dependency
    @Dependency(\.clubs) var clubsClient
    
    // MARK: - Action
    public enum Action: Equatable {
        case onAppear
        case loadClubs
        case receivedClubs(TaskResult<[ScienceClub]>)
        case listAction(ClubList.Action)
        case dismissKeyboard
        case showAlertStateChange(Bool)
        case destinations(StackAction<Destinations.State, Destinations.Action>)
    }
    
    // MARK: - Reducer
    public var body: some ReducerOf<Self> {
        
        Scope(
            state: \.listState,
            action: /ClubFeature.Action.listAction
        ) { () -> ClubList in
            ClubList()
        }
        
        Reduce { state, action in
            switch action {
            case .listAction(.navigateToDetails(let navState)):
                state.destinations.append(.details(navState))
                return .none
            case .listAction:
                return .none
            case .onAppear:
                if state.listState.clubs.isEmpty {
                    return .task { .loadClubs }
                } else {
                    return .none
                }
            case .loadClubs:
                return .task {
                    await .receivedClubs(TaskResult {
                        try await clubsClient.getScienceClubs(0)
                    })
                }
            case .receivedClubs(.success(let clubs)):
                return .task { .listAction(.receivedClubs(.success(clubs))) }
            case .receivedClubs(.failure):
                state.showAlert = true
                return .none
            case .dismissKeyboard:
                UIApplication.shared.dismissKeyboard()
                return .none
            case .showAlertStateChange(let newState):
                state.showAlert = newState
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
            case details(ClubDetails.State)
        }
        
        public enum Action: Equatable {
            case details(ClubDetails.Action)
        }
        
        public var body: some ReducerProtocol<State,Action> {
            EmptyReducer()
                .ifCaseLet(
                    /State.details,
                     action: /Action.details
                ) {
                    ClubDetails()
                }
        }
    }
    
}

//MARK: - VIEW
public struct ClubsView: View {
    let store: StoreOf<ClubFeature>
    
    public init(store: StoreOf<ClubFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStackStore(store.scope(
            state: \.destinations,
            action: ClubFeature.Action.destinations
        )) {
            WithViewStore(store, observe: { $0 }) { viewStore in
                ClubListView(
                    store: store.scope(
                        state: \.listState,
                        action: ClubFeature.Action.listAction
                    )
                )
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .alert(
                    isPresented: Binding(
                        get: { viewStore.showAlert },
                        set: { viewStore.send(.showAlertStateChange($0)) }
                    )
                ) {
                    // TODO: - Modify this to use AlerState
                    Alert(
                        title: Text(Strings.Other.networkError),
                        primaryButton: .default(
                            Text(Strings.Other.tryAgain),
                            action: {
                                viewStore.send(.loadClubs)
                            } ),
                        secondaryButton: .cancel(Text(Strings.Other.cancel))
                    )
                }
            }
        } destination: {
            switch $0 {
            case .details:
                CaseLet(
                    /ClubFeature.Destinations.State.details,
                     action: ClubFeature.Destinations.Action.details,
                     then: ClubDetailsView.init(store:)
                )
            }
        }
    }
}


#if DEBUG
// MARK: - Mock
extension ClubFeature.State {
    static let mock: Self = .init()
}

// MARK: - Preview
private struct ClubsView_Preview: PreviewProvider {
    static var previews: some View {
        ClubsView(
            store: .init(
                initialState: .mock,
                reducer: ClubFeature()
            )
        )
    }
}

#endif

