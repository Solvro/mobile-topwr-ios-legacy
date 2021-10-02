import SwiftUI
import ComposableArchitecture

//MARK: - STATE
public struct SplashState: Equatable {
    var text: String = "Hello World ToPwr"
    var isButtonTapped: Bool = false
    public init(){}
}
//MARK: - ACTION
public enum SplashAction: Equatable {
    case buttonTapped
}

//MARK: - ENVIRONMENT
public struct SplashEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let splashReducer = Reducer<
    SplashState,
    SplashAction,
    SplashEnvironment
> { state, action, environment in
  switch action {
  case .buttonTapped:
    state.isButtonTapped.toggle()
    return .none
  }
}

//MARK: - VIEW
public struct SplashView: View {
    let store: Store<SplashState, SplashAction>
    
    public init(
        store: Store<SplashState, SplashAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.gray
                    .ignoresSafeArea()
                
                VStack {
                    Text(viewStore.text)
                    
                    if viewStore.isButtonTapped {
                        Text("Text1")
                    } else {
                        Text("Text2")
                    }
                    
                    Button(action: {
                        viewStore.send(.buttonTapped)
                    },
                    label: {
                        Text("Button")
                    })
                }
            }
        }
    }
}

#if DEBUG
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(
            store: Store(
                initialState: .init(),
                reducer: splashReducer,
                environment: .init(mainQueue: .immediate)
            )
        )
    }
}
#endif
