import SwiftUI
import ComposableArchitecture
import Combine
import Common
import MenuFeature

//MARK: - STATE
public struct SplashState: Equatable {
    var isLoading: Bool = true
    
    var menuState = MenuState()
    public init(){}
}
//MARK: - ACTION
public enum SplashAction: Equatable {
    case stopLoading
    case menuAction(MenuAction)
}

//MARK: - ENVIRONMENT
public struct SplashEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var getSessionDate: () -> AnyPublisher<SessionDay, ErrorModel>
    var getDepartments: () -> AnyPublisher<[Department], ErrorModel>
    var getBuildings: () -> AnyPublisher<[Map], ErrorModel>
    var getScienceClubs: () -> AnyPublisher<[ScienceClub], ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getSessionDate: @escaping () -> AnyPublisher<SessionDay, ErrorModel>,
        getDepartments: @escaping () -> AnyPublisher<[Department], ErrorModel>,
        getBuildings: @escaping () -> AnyPublisher<[Map], ErrorModel>,
        getScienceClubs: @escaping () -> AnyPublisher<[ScienceClub], ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getSessionDate = getSessionDate
        self.getDepartments = getDepartments
        self.getBuildings = getBuildings
        self.getScienceClubs = getScienceClubs
    }
}

//MARK: - REDUCER
public let splashReducer = Reducer<
    SplashState,
    SplashAction,
    SplashEnvironment
> { state, action, environment in
  switch action {
  case .stopLoading:
      #warning("TODO")
    state.isLoading = false
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
                        getDepartments: env.getDepartments,
                        getBuildings: env.getBuildings,
                        getScienceClubs: env.getScienceClubs
                    )
            }
        )
)

//MARK: - VIEW
public struct SplashView: View {
    let store: Store<SplashState, SplashAction>
    
    @State var scale: CGFloat = 1.0
    
    var repeatingAnimation: Animation {
        Animation
            .easeInOut(duration: 1.2)
            .repeatForever()
    }
    
    public init(
        store: Store<SplashState, SplashAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                if viewStore.isLoading {
                    ZStack {
                        LinearGradient(
                            colors: [
                                K.Colors.firstColorLight,
                                K.Colors.firstColorDark
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                            .ignoresSafeArea()
                            .onTapGesture {
                                viewStore.send(.stopLoading)
                            }
                        
                        VStack {
                            K.Images.logoTemplate
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color.white)
                                .shadow(
                                    color: .black.opacity(0.2),
                                    radius: 2,
                                    x: 0,
                                    y: 2
                                )
                                .scaleEffect(scale)
                                .onAppear() {
                                    withAnimation(self.repeatingAnimation) { self.scale = 1.1 }
                                }
                        }
                        .frame(width: 200)
                    }
                } else {
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
                    getDepartments: failing0,
                    getBuildings: failing0,
                    getScienceClubs: failing0
                )
            )
        )
    }
}
#endif
