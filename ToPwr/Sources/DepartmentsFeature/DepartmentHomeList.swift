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
    
    public init() {}
    
    // MARK: - Action
    public enum Action: Equatable {
        case listButtonTapped
        case navigateToDetails(DepartmentDetails.State)
        case departmentDetailsAction(DepartmentDetails.Action)
        case fetchingOn
        case receivedDepartments(TaskResult<[Department]>)
        case loadMoreDepartments
    }
    
    // MARK: - Dependencies
    
    @Dependency(\.departments) var departmentsClient
    
    // MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .listButtonTapped:
                return .none
            case .departmentDetailsAction(_):
                return .none
            case .loadMoreDepartments:
                return .task { [count = state.departments.count] in
                    await .receivedDepartments(TaskResult{
                        try await departmentsClient.getDepartments(count)
                    })
                }
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
                        Button {
                            viewStore.send(.navigateToDetails(department))
                        } label: {
                            DepartmentCellView(state: department, isHomeCell: true)
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
