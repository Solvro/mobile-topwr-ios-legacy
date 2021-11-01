import ComposableArchitecture
import SplashFeature
import CoreLogic
import Common

private let coreLogic: CoreLogic = CoreLogic()

private let store = Store(
    initialState: SplashState(),
    reducer: splashReducer,
    environment: env()
)

public let splashView: SplashView = SplashView(
    store: store
)

private func env() -> SplashEnvironment {
    .init(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        getSessionDate: coreLogic.getSessionDate,
        getDepartments: coreLogic.getDepartments
    )
}
