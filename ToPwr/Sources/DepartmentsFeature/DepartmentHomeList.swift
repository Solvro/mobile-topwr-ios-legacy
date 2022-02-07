import SwiftUI
import ComposableArchitecture
import Combine
import Common

//MARK: - STATE
public struct DepartmentHomeListState: Equatable {
    let title: String = Strings.HomeLists.departmentListTitle
    let buttonText: String = Strings.HomeLists.departmentListButton
    
    var departments: IdentifiedArrayOf<DepartmentDetailsState>
    var selection: Identified<DepartmentDetailsState.ID, DepartmentDetailsState?>?
    
    var isLoading: Bool {
        departments.isEmpty ? true : false
    }
    
    public init(
        departments: [DepartmentDetailsState] = []
    ){
        self.departments = .init(uniqueElements: departments)
    }
}

//MARK: - ACTION
public enum DepartmentHomeListAction: Equatable {
    case listButtonTapped
    case setNavigation(selection: UUID?)
    case departmentDetailsAction(DepartmentDetailsAction)
}

//MARK: - ENVIRONMENT
public struct DepartmentHomeListEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getScienceClub: (Int) -> AnyPublisher<ScienceClub, ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getScienceClub: @escaping (Int) -> AnyPublisher<ScienceClub, ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getScienceClub = getScienceClub
    }
}

//MARK: - REDUCER

public let departmentHomeListReducer =
departmentDetailsReducer
.optional()
.pullback(state: \Identified.value, action: .self, environment: { $0 })
.optional()
.pullback(
  state: \DepartmentHomeListState.selection,
  action: /DepartmentHomeListAction.departmentDetailsAction,
  environment: {
      .init(
        mainQueue: $0.mainQueue,
        getScienceClub: $0.getScienceClub
      )
  }
)
.combined(
    with: Reducer<
    DepartmentHomeListState,
    DepartmentHomeListAction,
    DepartmentHomeListEnvironment
    > { state, action, env in
        switch action {
        case .listButtonTapped:
            return .none
        case let .setNavigation(selection: .some(id)):
            state.selection = Identified(nil, id: id)
            guard let id = state.selection?.id,
                  let department = state.departments[id: id] else { return .none }
            state.selection?.value = department
            return .none
        case .setNavigation(selection: .none):
            state.selection = nil
            return .none
        case .departmentDetailsAction(_):
            return .none
        }
    }
)
//MARK: - VIEW
public struct DepartmentHomeListView: View {
    let store: Store<DepartmentHomeListState, DepartmentHomeListAction>
    
    public init(
        store: Store<DepartmentHomeListState, DepartmentHomeListAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Text(viewStore.title)
                    .font(.appBoldTitle2)
                    .foregroundColor(K.FontColors.primary)
                Spacer()
                Button(
                    action: {
                        viewStore.send(.listButtonTapped)
                    },
                    label: {
                        Text(viewStore.buttonText)
                            .foregroundColor(.gray)
                            .font(.appRegularTitle3)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                )
            }
            .horizontalPadding(.normal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 18) {
                    ForEach(viewStore.departments) { department in
                        NavigationLink(
                          destination: IfLetStore(
                            self.store.scope(
                              state: \.selection?.value,
                              action: DepartmentHomeListAction.departmentDetailsAction
                            ),
                            then: DepartmentDetailsView.init(store:),
                            else: ProgressView.init
                          ),
                          tag: department.id,
                          selection: viewStore.binding(
                            get: \.selection?.id,
                            send: DepartmentHomeListAction.setNavigation(selection:)
                          )
                        ) {
                            DepartmentCellView(state: department, isHomeCell: true)
                        }
                    }
                }
                .horizontalPadding(.normal)
            }
        }
    }
}
