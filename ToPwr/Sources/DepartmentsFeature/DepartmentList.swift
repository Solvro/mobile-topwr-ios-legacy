import SwiftUI
import ComposableArchitecture
import Common

//MARK: - STATE
public struct DepartmentListState: Equatable {
    var departments: IdentifiedArrayOf<DepartmentDetailsState>
    var filtered: IdentifiedArrayOf<DepartmentDetailsState>
    var selection: Identified<DepartmentDetailsState.ID, DepartmentDetailsState?>?
    
    var searchState = SearchState()
    var text: String = ""
    
    var isLoading: Bool {
        departments.isEmpty ? true : false
    }
    
    public init(
        departments: [Department] = []
    ) {
        self.departments = .init(
            uniqueElements: departments.map {
                DepartmentDetailsState(department: $0)
            }
        )
        self.filtered = self.departments
    }
}

//MARK: - ACTION
public enum DepartmentListAction: Equatable {
    case listButtonTapped
    case searchAction(SearchAction)
    case setNavigation(selection: UUID?)
    case setNavigationSelectionCompleted
    case departmentDetailsAction(DepartmentDetailsAction)
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
public let departmentListReducer =
departmentDetailsReducer
.optional()
.pullback(state: \Identified.value, action: .self, environment: { $0 })
.optional()
.pullback(
  state: \DepartmentListState.selection,
  action: /DepartmentListAction.departmentDetailsAction,
  environment: { _ in DepartmentDetailsEnvironment() }
)
.combined(
    with: Reducer<
    DepartmentListState,
    DepartmentListAction,
    DepartmentListEnvironment
    > { state, action, env in
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
        case let .setNavigation(selection: .some(id)):
            state.selection = Identified(nil, id: id)
            return Effect(value: .setNavigationSelectionCompleted)
        case .setNavigation(selection: .none):
            state.selection = nil
            return .none
        case .setNavigationSelectionCompleted:
          guard let id = state.selection?.id,
            let department = state.filtered[id: id] else { return .none }
            state.selection?.value = department
          return .none
        case .departmentDetailsAction:
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
                            ForEach(viewStore.filtered) { department in
                                NavigationLink(
                                  destination: IfLetStore(
                                    self.store.scope(
                                      state: \.selection?.value,
                                      action: DepartmentListAction.departmentDetailsAction
                                    ),
                                    then: DepartmentDetailsView.init(store:),
                                    else: ProgressView.init
                                  ),
                                  tag: department.id,
                                  selection: viewStore.binding(
                                    get: \.selection?.id,
                                    send: DepartmentListAction.setNavigation(selection:)
                                  )
                                ) {
                                    DepartmentCellView(state: department)
                                }
                            }
                        }
                    }
                }
                .barLogo()
                .navigationTitle(Strings.HomeLists.departmentListTitle)
            }
        }
    }
}
