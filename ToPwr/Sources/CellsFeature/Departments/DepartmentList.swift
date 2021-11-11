import SwiftUI
import ComposableArchitecture
import Strings

//MARK: - STATE
public struct DepartmentListState: Equatable {
    let title: Text = Strings.DepartmentList.welcomeText
    let buttonText: Text = Strings.DepartmentList.button
    var departments: IdentifiedArrayOf<DepartmentCellState> = []
    
    var isLoading: Bool {
        departments.isEmpty ? true : false
    }
    
    public init(
        departments: [DepartmentCellState] = []
    ){
        self.departments = .init(uniqueElements: departments)
    }
}

//MARK: - ACTION
public enum DepartmentListAction: Equatable {
    case buttonTapped
    case listButtonTapped
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
            case .buttonTapped:
                print("CELL TAPPED")
                return .none
            case .listButtonTapped:
                return .none
            case .cellAction:
                return .none
            }
        }
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
            VStack {
                HStack {
                    viewStore.title
                        .font(.appBoldTitle1)
                    Spacer()
                    Button(
                        action: {
                            viewStore.send(.listButtonTapped)
                        },
                        label: {
                            viewStore.buttonText
                                .foregroundColor(.gray)
                                .font(.appRegular1)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    )
                }
                .padding([.leading, .trailing], 10)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEachStore(
                            self.store.scope(
                                state: \.departments,
                                action: DepartmentListAction.cellAction(id:action:)
                            )
                        ) { store in
                            DepartmentCellView(store: store)
                        }
                    }
                    .padding(.leading, 10)
                }
            }
            .padding(.bottom, 30)
        }
    }
}
