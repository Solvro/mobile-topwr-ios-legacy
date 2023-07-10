import SwiftUI
import ComposableArchitecture
import Combine
import Common

public struct DepartmentFeature: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        var listState = DepartmentList.State()
        var showAlert = false
        
        public init(){}
    }
    
    // MARK: - Action
    public enum Action: Equatable {
        case onAppear
        case loadDepartments
        case receivedDepartments(Result<[Department], ErrorModel>)
        case listAction(DepartmentList.Action)
        case dismissKeyboard
        case showAlertStateChange(Bool)
    }
    
    public init() {}
    
    // MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        
        Scope(
            state: \.listState,
            action: /Action.listAction
        ) { () -> DepartmentList in
            DepartmentList()
        }
        
        Reduce { state, action in
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
//                return env.getDepartments(0)
//                    .receive(on: env.mainQueue)
//                    .catchToEffect()
//                    .map(DepartmentsAction.receivedDepartments)
                return .none
            case .receivedDepartments(.success(let departments)):
                let sortedDepartments = departments.sorted(by: { $0.id < $1.id})
                state.listState = .init(
                  departments: sortedDepartments
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
    }
}

//MARK: - VIEW
public struct DepartmentsView: View {
    let store: StoreOf<DepartmentFeature>
    
    public init(store: StoreOf<DepartmentFeature>) {
        self.store = store
    }
    
    public var body: some View {
		WithViewStore(store) { viewStore in
			DepartmentListView(
				store: self.store.scope(
					state: \.listState,
                    action: DepartmentFeature.Action.listAction
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
					title: Text(Strings.Other.networkError),
					primaryButton: .default(
						Text(Strings.Other.tryAgain),
						action: {
							viewStore.send(.loadDepartments)
					} ),
					secondaryButton: .cancel(Text(Strings.Other.cancel))
				)
			}
		}
	}
}

#if DEBUG
// MARK: - Mock
extension DepartmentFeature.State {
    static let mock: Self = .init()
}

// MARK: - Preview
private struct DepartmentFeatureView_Preview: PreviewProvider {
    static var previews: some View {
        DepartmentsView(
            store: .init(
                initialState: .mock,
                reducer: DepartmentFeature()
            )
        )
    }
}
#endif
