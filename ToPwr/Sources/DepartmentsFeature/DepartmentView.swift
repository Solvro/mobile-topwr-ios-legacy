import SwiftUI
import ComposableArchitecture
import Combine
import Common

//MARK: - STATE
public struct DepartmentsState: Equatable {
    var listState = DepartmentListState()
    
    public init(){}
}
//MARK: - ACTION
public enum DepartmentsAction: Equatable {
    case onAppear
    case loadDepartments
    case receivedDepartments(Result<[Department], ErrorModel>)
    case listAction(DepartmentListAction)
    case dismissKeyboard
}

//MARK: - ENVIRONMENT
public struct DepartmentsEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getDepartments: (Int) -> AnyPublisher<[Department], ErrorModel>
    let getScienceClub: (Int) -> AnyPublisher<ScienceClub, ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getDepartments: @escaping (Int) -> AnyPublisher<[Department], ErrorModel>,
        getScienceClub: @escaping (Int) -> AnyPublisher<ScienceClub, ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getDepartments = getDepartments
        self.getScienceClub = getScienceClub
    }
}

//MARK: - REDUCER
public let DepartmentsReducer = Reducer<
    DepartmentsState,
    DepartmentsAction,
    DepartmentsEnvironment
> { state, action, env in
    switch action {
    case .listAction:
        return .none
    case .onAppear:
        if state.listState.departments.isEmpty {
            return .init(value: .loadDepartments)
        } else {
            return .none
        }
    case .loadDepartments:
        return env.getDepartments(0)
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map(DepartmentsAction.receivedDepartments)
    case .receivedDepartments(.success(let departments)):
        state.listState = .init(
          departments: departments
        )
        return .none
    case .receivedDepartments:
        return .none
    case .dismissKeyboard:
        UIApplication.shared.dismissKeyboard()
        return .none
    }
}
.combined(
    with: departmentListReducer
        .pullback(
            state: \.listState,
            action: /DepartmentsAction.listAction,
            environment: { env in
                    .init(
                        mainQueue: env.mainQueue,
                        getScienceClub: env.getScienceClub,
                        getDepatrements: env.getDepartments
                    )
            }
        )
)

//MARK: - VIEW
public struct DepartmentsView: View {
    let store: Store<DepartmentsState, DepartmentsAction>
    
    public init(
        store: Store<DepartmentsState, DepartmentsAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                DepartmentListView(
                    store: self.store.scope(
                        state: \.listState,
                        action: DepartmentsAction.listAction
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
        DepartmentsView(
            store: Store(
                initialState: .init(),
                reducer: DepartmentsReducer,
                environment: .failing
            )
        )
    }
}

public extension DepartmentsEnvironment {
    static let failing: Self = .init(
        mainQueue: .immediate,
        getDepartments: failing1,
        getScienceClub: failing1
    )
}
#endif
