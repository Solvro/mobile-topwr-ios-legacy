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
        getWelcomeDayText: coreLogic.getWelcomeDayText,
        getDepartment: coreLogic.getDepartment,
        getScienceClub: coreLogic.getScienceClub,
        getWhatsNew: coreLogic.getWhatsNew,
        getInfos: coreLogic.getInfos
    )
}
//
//extension SplashEnvironment {
//	static let mock: Self = .init(
//		mainQueue: .main.eraseToAnyScheduler(),
//		getApiVersion: {
//			return Just(Ver)
//		},
//		getSessionDate: <#T##() -> AnyPublisher<SessionDay, ErrorModel>#>,
//		getDepartments: <#T##() -> AnyPublisher<[Department], ErrorModel>#>,
//		getBuildings: <#T##() -> AnyPublisher<[Map], ErrorModel>#>,
//		getScienceClubs: <#T##() -> AnyPublisher<[ScienceClub], ErrorModel>#>,
//		getWelcomeDayText: <#T##() -> AnyPublisher<ExceptationDays, ErrorModel>#>,
//		getDepartment: <#T##(Int) -> AnyPublisher<Department, ErrorModel>#>,
//		getScienceClub: <#T##(Int) -> AnyPublisher<ScienceClub, ErrorModel>#>,
//		getWhatsNew: <#T##() -> AnyPublisher<[WhatsNew], ErrorModel>#>,
//		getInfos: <#T##() -> AnyPublisher<[Info], ErrorModel>#>
//	)
//}
