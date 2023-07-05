import ComposableArchitecture
import SplashFeature
import CoreLogic
import Common
import Combine
import Foundation

private let coreLogic: CoreLogic = CoreLogic()

private let store = Store(
    initialState: SplashState(),
    reducer: splashReducer,
    environment: env()
)

private let mainQueue = DispatchQueue.main.eraseToAnyScheduler()

public let splashView: SplashView = SplashView(
    store: store
)

private func env() -> SplashEnvironment {
    .init(
        mainQueue: mainQueue,
        getApiVersion: coreLogic.getApiVersion,
        getSessionDate: coreLogic.getSessionDate,
        getDepartments: coreLogic.getDepartments,
        getBuildings: coreLogic.getBuildings,
		getScienceClubs: coreLogic.getScienceClubs,
		getAllScienceClubs: coreLogic.getAllScienceClubs,
        getWelcomeDayText: coreLogic.getWelcomeDayText,
        getDepartment: coreLogic.getDepartment,
        getScienceClub: coreLogic.getScienceClub,
        getWhatsNew: coreLogic.getWhatsNew,
        getInfos: coreLogic.getInfos,
		getAboutUs: coreLogic.getAboutUs
    )
}
