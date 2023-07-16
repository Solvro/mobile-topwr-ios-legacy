import SwiftUI
import ComposableArchitecture
import Combine
import Common

public struct DepartmentHomeList: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        let title: String = Strings.HomeLists.departmentListTitle
        let buttonText: String = Strings.HomeLists.departmentListButton
        
        var departments: IdentifiedArrayOf<DepartmentDetails.State>
        var selection: DepartmentDetails.State?
        var isFetching = false
        var noMoreFetches = false
        
        public init(departments: [DepartmentDetails.State] = []) {
            self.departments = .init(uniqueElements: departments)
        }
    }
    
    // MARK: - Action
    public enum Action: Equatable {
        case listButtonTapped
        case setNavigation(selection: UUID?)
        case departmentDetailsAction(DepartmentDetails.Action)
        
        case fetchingOn
        case receivedDepartments(Result<[Department], ErrorModel>)
        case loadMoreDepartments
    }
    
    // MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .listButtonTapped:
                return .none
            case let .setNavigation(selection: .some(id)):
//                state.selection = Identified(nil, id: id)
//                guard let id = state.selection?.id,
//                      let department = state.departments[id: id] else { return .none }
//                state.selection?.value = department
                return .none
            case .setNavigation(selection: .none):
                state.selection = nil
                return .none
            case .departmentDetailsAction(_):
                return .none
            case .loadMoreDepartments:
//                return env.getDepatrements(state.departments.count)
//                    .receive(on: env.mainQueue)
//                    .catchToEffect()
//                    .map(DepartmentHomeListAction.receivedDepartments)
                return .none
            case .receivedDepartments(.success(let clubs)):
                if clubs.isEmpty {
                    state.noMoreFetches = true
                    state.isFetching = false
                    return .none
                }
                clubs.forEach { state.departments.append(DepartmentDetails.State(department: $0)) }
                return .none
            case .fetchingOn:
                state.isFetching = true
                return .none
            case .receivedDepartments(.failure(_)):
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
public struct DepartmentHomeListView: View {
    let store: StoreOf<DepartmentHomeList>
    
    public init(store: StoreOf<DepartmentHomeList>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Text(viewStore.title)
                    .font(.appMediumTitle2)
                    .foregroundColor(K.FontColors.primary)
                Spacer()
                Button(
                    action: {
                        viewStore.send(.listButtonTapped)
                    },
                    label: {
                        Text(viewStore.buttonText)
                            .foregroundColor(K.Colors.red)
                            .font(.appRegularTitle3)
                        Image(systemName: "chevron.right")
                            .foregroundColor(K.Colors.red)
                    }
                )
            }
            .horizontalPadding(.normal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 18) {
                    ForEach(viewStore.departments) { department in
                        DepartmentCellView(state: department, isHomeCell: true)
                            .onAppear {
                                if !viewStore.noMoreFetches {
                                    viewStore.send(.fetchingOn)
                                    if department.id == viewStore.departments.last?.id {
                                        viewStore.send(.loadMoreDepartments)
                                    }
                                }
                            }
                        // FIXME: - Implement proper navigation
//                        NavigationLink(
//                          destination: IfLetStore(
//                            self.store.scope(
//                              state: \.selection?.value,
//                              action: DepartmentHomeList.Action.departmentDetailsAction
//                            ),
//                            then: DepartmentDetailsView.init(store:),
//                            else: ProgressView.init
//                          ),
//                          tag: department.id,
//                          selection: viewStore.binding(
//                            get: \.selection?.id,
//                            send: DepartmentHomeList.Action.setNavigation(selection:)
//                          )
//                        ) {
//
//                        }
                    }
                    if viewStore.isFetching { ProgressView() }
                }
                .horizontalPadding(.normal)
            }
        }
    }
}

#if DEBUG
// MARK: - Mock
extension DepartmentHomeList.State {
    static let mock: Self = .init()
}

// MARK: - Preview
private struct DepartmentHomeListView_Preview: PreviewProvider {
    static var previews: some View {
        DepartmentHomeListView(
            store: .init(
                initialState: .mock,
                reducer: DepartmentHomeList()
            )
        )
    }
}

#endif
