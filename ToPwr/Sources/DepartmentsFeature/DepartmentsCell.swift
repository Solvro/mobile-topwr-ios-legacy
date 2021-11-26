import SwiftUI
import ComposableArchitecture
import Common

//MARK: - STATE
public struct DepartmentCellState: Equatable, Identifiable {
    public let id: Int
    let department: Department

    public init(
        department: Department
    ){
        self.id = department.id
        self.department = department
    }
}
//MARK: - ACTION
public enum DepartmentCellAction: Equatable {
    case buttonTapped
}

//MARK: - ENVIRONMENT
public struct DepartmentCellEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let departmentCellReducer = Reducer<
    DepartmentCellState,
    DepartmentCellAction,
    DepartmentCellEnvironment
> { state, action, environment in
  switch action {
  case .buttonTapped:
      print("Departament Button Tapped")
    return .none
  }
}

//MARK: - VIEW
public struct DepartmentCellView: View {
    let store: Store<DepartmentCellState, DepartmentCellAction>
    
    public init(
        store: Store<DepartmentCellState, DepartmentCellAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            Button(
                action: {
                    viewStore.send(.buttonTapped)
                },
                label: {
                    ZStack(alignment: .leading) {
                        BanerView(
                            url: URL(string: viewStore.department.logo?.url ?? ""),
                            color: viewStore.department.color
                        )
                        .frame(width: 360, height: 120)
                        .cornerRadius(8)
                        
                        VStack(alignment: .leading) {
                                Text(viewStore.department.code ?? "")
                                    .bold()
                                    .font(.appBoldTitle3)
                                    .padding(.bottom, 10)

                                Text(viewStore.department.name ?? "")
                                    .font(.appRegularTitle3)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                        }
                        .foregroundColor(.white)
                        .padding([.top, .bottom, .leading], 15)
                    }
                }
            )
        }
    }
}

//MARK: - MOCKS & PREVIEW
#if DEBUG
public extension DepartmentCellState {
    static let mock: Self = .init(
        department: .mock
    )
    
    static func mocks(id: Int) -> Self {
        .init(
            department: .mock(id: id)
        )
    }
}
#endif
