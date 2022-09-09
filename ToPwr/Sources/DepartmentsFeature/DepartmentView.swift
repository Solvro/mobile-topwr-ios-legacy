import SwiftUI
import ComposableArchitecture
import Combine
import Common

//MARK: - STATE
public struct DepartmentsState: Equatable {
    var listState = DepartmentListState()
	var showAlert = false
    
    public init(){}
}
//MARK: - ACTION
public enum DepartmentsAction: Equatable {
    case onAppear
    case loadDepartments
    case receivedDepartments(Result<[Department], ErrorModel>)
    case listAction(DepartmentListAction)
    case dismissKeyboard
	case showAlertStateChange(Bool)
}

//MARK: - ENVIRONMENT
public struct DepartmentsEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getDepartments: () -> AnyPublisher<[Department], ErrorModel>
    let getScienceClub: (Int) -> AnyPublisher<ScienceClub, ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getDepartments: @escaping () -> AnyPublisher<[Department], ErrorModel>,
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
        return env.getDepartments()
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map(DepartmentsAction.receivedDepartments)
    case .receivedDepartments(.success(let departments)):
        state.listState = .init(
          departments: departments
        )
        return .none
	case .receivedDepartments(.failure(let error)):
		state.showAlert = true
        return .none
    case .dismissKeyboard:
        UIApplication.shared.dismissKeyboard()
        return .none
	case .showAlertStateChange(let newState):
		state.showAlert = newState
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
                        getScienceClub: env.getScienceClub
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
			DepartmentListView(
				store: self.store.scope(
					state: \.listState,
					action: DepartmentsAction.listAction
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
				Alert(
					title: Text("Problem z połączeniem"),
					primaryButton: .default(
						Text("Spróbuj ponownie"),
						action: {
							viewStore.send(.loadDepartments)
					} ),
					secondaryButton: .cancel(Text("Anuluj"))
				)
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
        getDepartments: failing0,
        getScienceClub: failing1
    )
}
#endif
