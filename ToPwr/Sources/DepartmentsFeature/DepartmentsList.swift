import SwiftUI
import ComposableArchitecture
import Common

//MARK: - STATE
public struct DepartmentListState: Equatable {
    var departments: IdentifiedArrayOf<DepartmentCellState>
    var filtered: IdentifiedArrayOf<DepartmentCellState>
    var searchState = SearchState()
    var text: String = ""
    
    var isLoading: Bool {
        departments.isEmpty ? true : false
    }
    
    public init(
        departments: [DepartmentCellState] = []
    ) {
        self.departments = .init(uniqueElements: departments)
        self.filtered = self.departments
    }
}

//MARK: - ACTION
public enum DepartmentListAction: Equatable {
    case listButtonTapped
    case searchAction(SearchAction)
    case cellAction(id: DepartmentCellState.ID, action: DepartmentCellAction)
}

//MARK: - ENVIRONMENT
public struct DepartmentListEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let departmentListReducer = Reducer<
    DepartmentListState,
    DepartmentListAction,
    DepartmentListEnvironment
>
    .combine(
        departmentCellReducer.forEach(
            state: \.departments,
            action: /DepartmentListAction.cellAction(id:action:),
            environment: { env in
                    .init(mainQueue: env.mainQueue)
            }
        ),
        Reducer{ state, action, environment in
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
            case .cellAction:
                return .none
            }
        }
    )
    .combined(
        with: searchReducer
            .pullback(
                state: \.searchState,
                action: /DepartmentListAction.searchAction,
                environment: { env in
                        .init(mainQueue: env.mainQueue)
                }
            )
    )

//MARK: - VIEW
public struct DepartmentListView: View {
    let store: Store<DepartmentListState, DepartmentListAction>
    
    public init(
        store: Store<DepartmentListState, DepartmentListAction>
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
                                action: DepartmentListAction.searchAction
                            )
                        ).padding(.bottom, 16)
                        
                        LazyVStack(spacing: 16) {
                            ForEachStore(
                                self.store.scope(
                                    state: \.filtered,
                                    action: DepartmentListAction.cellAction(id:action:)
                                )
                            ) { store in
                                DepartmentCellView(store: store)
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(
                        placement: .navigationBarLeading
                    ) {
                        HStack {
                            LogoView()
                                .aspectRatio(contentMode: .fit)
                            Spacer()
                        }
                        .frame(height: 20)
                        .padding([.bottom, .top], 10)
                    }
                }
                .navigationTitle(Strings.HomeLists.departmentListTitle)
            }
        }
    }
}
