import SwiftUI
import ComposableArchitecture

//MARK: - STATE
public struct BuildingCellState: Equatable, Identifiable {
    public let id: Int
    let imageURL: String
    let name: String
    
    public init(
        id: Int,
        imageURL: String,
        name: String
    ){
        self.id = id
        self.imageURL = imageURL
        self.name = name
    }
}
//MARK: - ACTION
public enum BuildingCellAction: Equatable {
    case buttonTapped
}

//MARK: - ENVIRONMENT
public struct BuildingCellEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let buildingCellReducer = Reducer<
    BuildingCellState,
    BuildingCellAction,
    BuildingCellEnvironment
> { state, action, environment in
  switch action {
  case .buttonTapped:
      print("Building Button Tapped")
    return .none
  }
}

//MARK: - VIEW
public struct BuildingCellView: View {
    let store: Store<BuildingCellState, BuildingCellAction>
    
    public init(
        store: Store<BuildingCellState, BuildingCellAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            Button(action: {
                print("BUILDING CELL TAPPED")
            }, label: {
                #warning("Replace with an ImageURL")
                ZStack(alignment: .bottomLeading) {
                    Image(viewStore.imageURL)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .cornerRadius(8)
                    Text(viewStore.name)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                }
            })
        }
    }
}

//MARK: - MOCKS & PREVIEW
#if DEBUG
public extension BuildingCellState {
    static let mock: Self = .init(
        id: 1,
        imageURL: "tree",
        name: "B-4")
    
    static func mocks(id: Int) -> Self {
        .init(
            id: id,
            imageURL: "tree",
            name: "B-\(id)"
        )
    }
}
#endif
