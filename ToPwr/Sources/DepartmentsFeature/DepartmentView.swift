import SwiftUI
import ComposableArchitecture
import Combine
import Common

public struct DepartmentFeature: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        var listState = DepartmentList.State()
        var showAlert = false
        var destinations = StackState<Destinations.State>()
        
        public init(){}
    }
    
    // MARK: - Action
    public enum Action: Equatable {
        case onAppear
        case loadDepartments
        case receivedDepartments(TaskResult<[Department]>)
        case listAction(DepartmentList.Action)
        case dismissKeyboard
        case showAlertStateChange(Bool)
        case destinations(StackAction<Destinations.State, Destinations.Action>)
    }
    
    public init() {}
    
    // MARK: - Dependency
    @Dependency(\.departments) var departmentsClient
    
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
            case .listAction(.navigateToDetails(let detailsState)):
                state.destinations.append(.details(detailsState))
                return .none
            case .listAction:
                return .none
            case .onAppear:
                if state.listState.departments.isEmpty {
                    return .init(value: .loadDepartments)
                }
                return .none
            case .loadDepartments:
                return .task {
                    await .receivedDepartments(TaskResult {
                        try await departmentsClient.getDepartments(0)
                    })
                }
            case .receivedDepartments(.success(let departments)):
                let sortedDepartments = departments.sorted(by: { $0.id < $1.id})
                state.listState = .init(
                  departments: sortedDepartments
                )
                return .none
            case .receivedDepartments(.failure):
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
            case details(DepartmentDetails.State)
        }
        
        public enum Action: Equatable {
            case details(DepartmentDetails.Action)
        }
        
        public var body: some ReducerProtocol<State,Action> {
            EmptyReducer()
                .ifCaseLet(
                    /State.details,
                     action: /Action.details
                ) {
                    DepartmentDetails()
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
        NavigationStackStore(store.scope(
            state: \.destinations,
            action: DepartmentFeature.Action.destinations
        )) {
            WithViewStore(store, observe: { $0 }) { viewStore in
                DepartmentListView(
                    store: store.scope(
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
        } destination: {
            switch $0 {
            case .details:
                CaseLet(
                    /DepartmentFeature.Destinations.State.details,
                     action: DepartmentFeature.Destinations.Action.details,
                     then: DepartmentDetailsView.init(store:)
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
