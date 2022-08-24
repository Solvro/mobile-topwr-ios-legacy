import SwiftUI
import ComposableArchitecture
import Combine
import Common

//MARK: - STATE
public struct DepartmentListState: Equatable {
    var departments: IdentifiedArrayOf<DepartmentDetailsState>
    var filtered: IdentifiedArrayOf<DepartmentDetailsState>
    var selection: Identified<DepartmentDetailsState.ID, DepartmentDetailsState?>?
    
    var searchState = SearchState()
    var text: String = ""
    var isFetching = false
    var noMoreFetches = false

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
    case departmentDetailsAction(DepartmentDetailsAction)
    case receivedDepartments(Result<[Department], ErrorModel>)
    case fetchingOn
    case loadMoreDepartments

}

//MARK: - ENVIRONMENT
public struct DepartmentListEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getScienceClub: (Int) -> AnyPublisher<ScienceClub, ErrorModel>
    let getDepatrements: (Int) -> AnyPublisher<[Department], ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getScienceClub: @escaping (Int) -> AnyPublisher<ScienceClub, ErrorModel>,
        getDepatrements: @escaping (Int) -> AnyPublisher<[Department], ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getScienceClub = getScienceClub
        self.getDepatrements = getDepatrements
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
  environment: {
      .init(
        mainQueue: $0.mainQueue,
        getScienceClub: $0.getScienceClub
      )
      
  }
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
            guard let id = state.selection?.id,
              let department = state.filtered[id: id] else { return .none }
              state.selection?.value = department
            return .none
        case .setNavigation(selection: .none):
            state.selection = nil
            return .none
        case .departmentDetailsAction:
            return .none
        case .loadMoreDepartments:
            return env.getDepatrements(state.departments.count)
                .receive(on: env.mainQueue)
                .catchToEffect()
                .map(DepartmentListAction.receivedDepartments)
        case .receivedDepartments(.success(let clubs)):
            if clubs.isEmpty {
                state.isFetching = false
                state.noMoreFetches = true
                return .none
            }
            clubs.forEach { state.departments.append(DepartmentDetailsState(department: $0)) }
            state.filtered = state.departments
            return .none
        case .fetchingOn:
            state.isFetching = true
            return .none
        case .receivedDepartments(.failure(_)):
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
                        }
                        if viewStore.isFetching { ProgressView() }
                    }
                }
                .barLogo()
                .navigationTitle(Strings.HomeLists.departmentListTitle)
            }
        }
    }
}
