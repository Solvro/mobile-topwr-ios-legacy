import SwiftUI
import ComposableArchitecture

//MARK: - STATE
public struct DepartmentCellState: Equatable, Identifiable {
    public let id: Int
    let imageURL: String
    let name: String
    let fullName: String
    
    public init(
        id: Int,
        imageURL: String,
        name: String,
        fullName: String
    ){
        self.id = id
        self.imageURL = imageURL
        self.name = name
        self.fullName = fullName
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
            Button(action: {
                viewStore.send(.buttonTapped)
            }, label: {
                ZStack(alignment: .bottomLeading) {
                #warning("Replace with an ImageURL")
                    Image(viewStore.imageURL)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 183, height: 162)
                        .cornerRadius(8)
                    VStack(alignment: .leading) {
                        Text(viewStore.name)
                            .bold()
                            .padding(.bottom, 10)
                        Text(viewStore.fullName)
                    }
                    .foregroundColor(.white)
                    .padding()
                }
            })
        }
    }
}

//MARK: - MOCKS & PREVIEW
#if DEBUG
public extension DepartmentCellState {
    static let mock: Self = .init(
        id: 1,
        imageURL: "tree",
        name: "WZD",
        fullName: "Wydział z Dupy"
    )
    
    static func mocks(id: Int) -> Self {
        .init(
            id: id,
            imageURL: "tree",
            name: "W-\(id)",
            fullName: "Wydział Kosmosu \(id)"
        )
    }
    
}
#endif
