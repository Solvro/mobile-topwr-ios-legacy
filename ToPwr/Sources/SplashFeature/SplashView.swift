import SwiftUI
import ComposableArchitecture
import Combine
import Common
import MenuFeature
import PureSwiftUI

//MARK: - STATE
public struct SplashState: Equatable {
    var isLoading: Bool = true {
        willSet {
            if !newValue {
                withAnimation {
                    showWritingAnimation = true
                }
            }
        }
    }
    var showWritingAnimation: Bool = false
    
    var menuState = MenuState()
    public init(){}
}
//MARK: - ACTION
public enum SplashAction: Equatable {
    case onAppear
    case apiVersion(Result<Version, ErrorModel>)
    case stopLoading
    case setWriting(Bool)
    case menuAction(MenuAction)
}

//MARK: - ENVIRONMENT
public struct SplashEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getApiVersion: () -> AnyPublisher<Version, ErrorModel>
    let getSessionDate: () -> AnyPublisher<SessionDay, ErrorModel>
    let getDepartments: () -> AnyPublisher<[Department], ErrorModel>
    let getBuildings: () -> AnyPublisher<[Map], ErrorModel>
    let getScienceClubs: () -> AnyPublisher<[ScienceClub], ErrorModel>
    let getWelcomeDayText: () -> AnyPublisher<ExceptationDays, ErrorModel>
    let getDepartment: (Int) -> AnyPublisher<Department, ErrorModel>
    let getScienceClub: (Int) -> AnyPublisher<ScienceClub, ErrorModel>
    let getWhatsNew: () -> AnyPublisher<[WhatsNew], ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getApiVersion: @escaping () -> AnyPublisher<Version, ErrorModel>,
        getSessionDate: @escaping () -> AnyPublisher<SessionDay, ErrorModel>,
        getDepartments: @escaping () -> AnyPublisher<[Department], ErrorModel>,
        getBuildings: @escaping () -> AnyPublisher<[Map], ErrorModel>,
        getScienceClubs: @escaping () -> AnyPublisher<[ScienceClub], ErrorModel>,
        getWelcomeDayText: @escaping () -> AnyPublisher<ExceptationDays, ErrorModel>,
        getDepartment: @escaping (Int) -> AnyPublisher<Department, ErrorModel>,
        getScienceClub: @escaping (Int) -> AnyPublisher<ScienceClub, ErrorModel>,
        getWhatsNew: @escaping () -> AnyPublisher<[WhatsNew], ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getApiVersion = getApiVersion
        self.getSessionDate = getSessionDate
        self.getDepartments = getDepartments
        self.getBuildings = getBuildings
        self.getScienceClubs = getScienceClubs
        self.getWelcomeDayText = getWelcomeDayText
        self.getDepartment = getDepartment
        self.getScienceClub = getScienceClub
        self.getWhatsNew = getWhatsNew
    }
}

//MARK: - REDUCER
public let splashReducer = Reducer<
    SplashState,
    SplashAction,
    SplashEnvironment
> { state, action, env in
  switch action {
  case .onAppear:
      return env.getApiVersion()
          .receive(on: env.mainQueue)
          .catchToEffect()
          .map(SplashAction.apiVersion)
  case .apiVersion(.success(let version)):
      return .init(value: .stopLoading)
  case .apiVersion(.failure(let error)):
      print(error.localizedDescription)
      return .none
  case .stopLoading:
    state.isLoading = false
    return .none
  case .setWriting(let newValue):
    state.showWritingAnimation = newValue
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
            environment: {
                    .init(
                        mainQueue: $0.mainQueue,
                        getSessionDate: $0.getSessionDate,
                        getDepartments: $0.getDepartments,
                        getBuildings: $0.getBuildings,
                        getScienceClubs: $0.getScienceClubs,
                        getWelcomeDayText: $0.getWelcomeDayText,
                        getDepartment: $0.getDepartment,
                        getScienceClub: $0.getScienceClub,
                        getWhatsNew: $0.getWhatsNew
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
//                    ZStack {
//                        LinearGradient(
//                            colors: [
//                                K.Colors.firstColorLight,
//                                K.Colors.firstColorDark
//                            ],
//                            startPoint: .leading,
//                            endPoint: .trailing
//                        )
//                            .ignoresSafeArea()
//                        VStack {
//                            K.Images.logoTemplate
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .foregroundColor(Color.white)
//                                .shadow(
//                                    color: .black.opacity(0.2),
//                                    radius: 2,
//                                    x: 0,
//                                    y: 2
//                                )
//                                .scaleEffect(scale)
//                                .onAppear() {
//                                    withAnimation(self.repeatingAnimation) { self.scale = 1.1 }
//                                }
//                        }
//                        .frame(width: 200)
//                    }
                    LoadingAnimation()
                }else if viewStore.showWritingAnimation{
                    HStack(spacing: 0){
                        ProgressView()
                    }.onAppear {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) { // change this accordingly
                            withAnimation {
                                viewStore.send(.setWriting(false))
                            }
                        }
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
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
    
    private struct T: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            return path
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
                    getApiVersion: failing0,
                    getSessionDate: failing0,
                    getDepartments: failing0,
                    getBuildings: failing0,
                    getScienceClubs: failing0,
                    getWelcomeDayText: failing0,
                    getDepartment: failing1,
                    getScienceClub: failing1,
                    getWhatsNew: failing0
                )
            )
        )
    }
}
#endif
