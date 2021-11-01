import SwiftUI
import ComposableArchitecture
import Combine
import Common
import MenuFeature

//MARK: - STATE
public struct SplashState: Equatable {
    var text: String = "Hello World ToPwr"
    var isButtonTapped: Bool = false
    
    var menuState = MenuState()
    public init(){}
}
//MARK: - ACTION
public enum SplashAction: Equatable {
    case buttonTapped
    case menuAction(MenuAction)
}

//MARK: - ENVIRONMENT
public struct SplashEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var getSessionDate: () -> AnyPublisher<SessionDay, ErrorModel>
    var getDepartments: () -> AnyPublisher<[Department], ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getSessionDate: @escaping () -> AnyPublisher<SessionDay, ErrorModel>,
        getDepartments: @escaping () -> AnyPublisher<[Department], ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getSessionDate = getSessionDate
        self.getDepartments = getDepartments
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
  case .menuAction:
      return .none
  }
}
.combined(
    with: menuReducer
        .pullback(
            state: \.menuState,
            action: /SplashAction.menuAction,
            environment: { env in
                    .init(
                        mainQueue: env.mainQueue,
                        getSessionDate: env.getSessionDate,
                        getDepartments: env.getDepartments
                    )
            }
        )
)

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
                
                MenuView(
                    store: self.store.scope(
                        state: \.menuState,
                        action: SplashAction.menuAction
                    )
                )
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
                environment: .init(
                    mainQueue: .immediate,
                    getSessionDate: failing0,
                    getDepartments: failing0
                )
            )
        )
    }
}
#endif
