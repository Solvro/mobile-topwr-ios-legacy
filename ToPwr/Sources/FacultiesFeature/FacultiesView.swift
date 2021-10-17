import SwiftUI
import ComposableArchitecture

//MARK: - STATE
public struct FacultiesState: Equatable {
    var text: String = "Hello World ToPwr"
    public init(){}
}
//MARK: - ACTION
public enum FacultiesAction: Equatable {
    case buttonTapped
}

//MARK: - ENVIRONMENT
public struct FacultiesEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let facultiesReducer = Reducer<
    FacultiesState,
    FacultiesAction,
    FacultiesEnvironment
> { state, action, environment in
  switch action {
  case .buttonTapped:
    return .none
  }
}

//MARK: - VIEW
public struct FacultiesView: View {
    let store: Store<FacultiesState, FacultiesAction>
    
    public init(
        store: Store<FacultiesState, FacultiesAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Text("FacultiesView")
            }
        }
    }
}

#if DEBUG
struct FacultiesView_Previews: PreviewProvider {
    static var previews: some View {
        FacultiesView(
            store: Store(
                initialState: .init(),
                reducer: facultiesReducer,
                environment: .init(mainQueue: .immediate)
            )
        )
    }
}
#endif
