import SwiftUI
import ComposableArchitecture
import Combine
import Common

public struct DepartmentList: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        var departments: IdentifiedArrayOf<DepartmentDetails.State>
        var filtered: IdentifiedArrayOf<DepartmentDetails.State>
        var selection: DepartmentDetails.State?
        
        // FIXME: - What placeholder?
        var searchState = SearchFeature.State(placeholder: "")
        var text: String = ""
        var isFetching = false
        var noMoreFetches = false
    
        public init(departments: [Department] = []) {
            self.departments = .init(
                uniqueElements: departments.map {
                    DepartmentDetails.State(department: $0)
                }
            )
            self.filtered = self.departments
        }
    }
    
    // MARK: - Action
    public enum Action: Equatable {
        case listButtonTapped
        case searchAction(SearchFeature.Action)
        case navigateToDetails(DepartmentDetails.State)
        case departmentDetailsAction(DepartmentDetails.Action)
        case receivedDepartments(TaskResult<[Department]>)
        case fetchingOn
        case loadMoreDepartments
    }
    
    // MARK: - Dependency
    @Dependency(\.departments) var departmentsClient
    
    // MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        
        Scope(
            state: \.searchState,
            action: /Action.searchAction
        ) { () -> SearchFeature in
            SearchFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .listButtonTapped:
                return .none
            case .searchAction(.update(let text)):
                state.text = text
                
                if text.count == 0 {
                    state.filtered = state.departments
                } else {
                    state.filtered = .init(
                        uniqueElements: state.departments.filter {
                            $0.department.name?.contains(text) ?? false ||
                            $0.department.description?.contains(text) ?? false ||
                            $0.department.code?.contains(text) ?? false
                        }
                    )
                }
                return .none
            case .searchAction:
                return .none
            case .departmentDetailsAction:
                return .none
            case .loadMoreDepartments:
                return .task { [start = state.departments.count] in
                    await .receivedDepartments(TaskResult {
                        try await departmentsClient.getDepartments(start)
                    })
                }
            case .receivedDepartments(.success(let departments)):
                if departments.isEmpty {
                    state.isFetching = false
                    state.noMoreFetches = true
                    return .none
                }
                departments.forEach {
                    state.departments.append(DepartmentDetails.State(department: $0))
                }
                state.filtered = state.departments
                return .none
            case .fetchingOn:
                state.isFetching = true
                return .none
            case .receivedDepartments(.failure(_)):
                return .none
            case .navigateToDetails:
                return .none
            }
        }
        .ifLet(
            \.selection,
             action: /Action.departmentDetailsAction
        ) {
            DepartmentDetails()
        }
    }
}

//MARK: - VIEW
public struct DepartmentListView: View {
    let store: StoreOf<DepartmentList>
    
    public init(store: StoreOf<DepartmentList>) {
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
                                action: DepartmentList.Action.searchAction
                            )
                        ).padding(.bottom, 16)
                        
                        LazyVStack(spacing: 16) {
                            ForEach(viewStore.filtered) { department in
                                Button {
                                    viewStore.send(.navigateToDetails(department))
                                } label: {
                                    DepartmentCellView(state: department)
                                }
                                .onAppear {
                                    if !viewStore.noMoreFetches {
                                        viewStore.send(.fetchingOn)
                                        if department.id == viewStore.departments.last?.id {
                                            viewStore.send(.loadMoreDepartments)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, UIDimensions.normal.size)
                        if viewStore.isFetching { ProgressView() }
                    }
                }
                .barLogo()
                .navigationTitle(Strings.HomeLists.departmentListTitle)
            }
        }
    }
}

#if DEBUG
// MARK: - Mock
extension DepartmentList.State {
    static let mock: Self = .init()
}

// MARK: - Preview
private struct DepartmentListView_Preview: PreviewProvider {
    static var previews: some View {
        DepartmentListView(
            store: .init(
                initialState: .mock,
                reducer: DepartmentList()
            )
        )
    }
}

#endif
