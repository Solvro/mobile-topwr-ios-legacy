import SwiftUI
import ComposableArchitecture

//MARK: - STATE
public struct InfoState: Equatable {
    var text: String = "Hello World ToPwr"
    public init(){}
}
//MARK: - ACTION
public enum InfoAction: Equatable {
    case buttonTapped
}

//MARK: - ENVIRONMENT
public struct InfoEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let infoReducer = Reducer<
    InfoState,
    InfoAction,
    InfoEnvironment
> { state, action, environment in
  switch action {
  case .buttonTapped:
    return .none
  }
}

//MARK: - VIEW
public struct InfoView: View {
    let store: Store<InfoState, InfoAction>
    
    public init(
        store: Store<InfoState, InfoAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Text("InfoView")
            }
        }
    }
}

#if DEBUG
struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(
            store: Store(
                initialState: .init(),
                reducer: infoReducer,
                environment: .init(mainQueue: .immediate)
            )
        )
    }
}
#endif
