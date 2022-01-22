import SwiftUI
import ComposableArchitecture
import Combine
import Common

//MARK: - STATE
public struct ClubsState: Equatable {
    
    var listState = ClubListState()
    
    public init(){}
}
//MARK: - ACTION
public enum ClubsAction: Equatable {
    case onAppear
    case loadClubs
    case receivedClubs(Result<[ScienceClub], ErrorModel>)
    case listAction(ClubListAction)
    case dismissKeyboard
}

//MARK: - ENVIRONMENT
public struct ClubsEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getClubs: () -> AnyPublisher<[ScienceClub], ErrorModel>
    let getDepartment: (Int) -> AnyPublisher<Department, ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getClubs: @escaping () -> AnyPublisher<[ScienceClub], ErrorModel>,
        getDepartment: @escaping (Int) -> AnyPublisher<Department, ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getClubs = getClubs
        self.getDepartment = getDepartment
    }
}

//MARK: - REDUCER
public let ClubsReducer = Reducer<
    ClubsState,
    ClubsAction,
    ClubsEnvironment
> { state, action, env in
    switch action {
    case .listAction:
        return .none
    case .onAppear:
        if state.listState.clubs.isEmpty {
            return .init(value: .loadClubs)
        } else {
            return .none
        }
    case .loadClubs:
        return env.getClubs()
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map(ClubsAction.receivedClubs)
    case .receivedClubs(.success(let clubs)):
        state.listState = .init(clubs: clubs)
        return .none
    case .receivedClubs:
        return .none
    case .dismissKeyboard:
        UIApplication.shared.dismissKeyboard()
        return .none
    }
}
.combined(
    with: clubListReducer
        .pullback(
            state: \.listState,
            action: /ClubsAction.listAction,
            environment: {
                .init(
                    mainQueue: $0.mainQueue,
                    getDepartment: $0.getDepartment
                )
            }
        )
)
//MARK: - VIEW
public struct ClubsView: View {
    let store: Store<ClubsState, ClubsAction>
    
    public init(
        store: Store<ClubsState, ClubsAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                ClubListView(
                    store: self.store.scope(
                        state: \.listState,
                        action: ClubsAction.listAction
                    )
                )
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

#if DEBUG
struct DepartmentsView_Previews: PreviewProvider {
    static var previews: some View {
        ClubsView(
            store: Store(
                initialState: .init(),
                reducer: ClubsReducer,
                environment: .failing
            )
        )
    }
}

public extension ClubsEnvironment {
    static let failing: Self = .init(
        mainQueue: .immediate,
        getClubs: failing0,
        getDepartment: failing1
    )
}
#endif

