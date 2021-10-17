import SwiftUI
import ComposableArchitecture

//MARK: - STATE
public struct ClubsState: Equatable {
    var text: String = "Hello World ToPwr"
    public init(){}
}
//MARK: - ACTION
public enum ClubsAction: Equatable {
    case buttonTapped
}

//MARK: - ENVIRONMENT
public struct ClubsEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let clubsReducer = Reducer<
    ClubsState,
    ClubsAction,
    ClubsEnvironment
> { state, action, environment in
  switch action {
  case .buttonTapped:
    return .none
  }
}

//MARK: - VIEW
public struct ClubsView: View {
    let store: Store<ClubsState, ClubsAction>
    
    public init(
        store: Store<ClubsState, ClubsAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Text("ClubsView")
            }
        }
    }
}

#if DEBUG
struct ClubsView_Previews: PreviewProvider {
    static var previews: some View {
        ClubsView(
            store: Store(
                initialState: .init(),
                reducer: clubsReducer,
                environment: .init(mainQueue: .immediate)
            )
        )
    }
}
#endif
