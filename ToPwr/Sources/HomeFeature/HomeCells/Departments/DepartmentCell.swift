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
                    ZStack(alignment: .bottomLeading) {
                        ImageView(
                            url: URL(string: viewStore.department.photo?.url ?? ""),
                            contentMode: .aspectFill
                        )
                            .frame(width: 183, height: 162)
                        
                        LinearGradient(
                            gradient: Gradient(
                                colors: [.gray, .clear]
                            ),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        VStack(alignment: .leading) {
                            Text(viewStore.department.code ?? "")
                                .bold()
                                .font(.appBoldTitle1)
                            Text(viewStore.department.name ?? "")
                                .multilineTextAlignment(.leading)
                                .font(.appRegular2)
                        }
                        .foregroundColor(.white)
                        .padding(10)
                    }
                    .frame(width: 183, height: 162)
                    .cornerRadius(8)
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
