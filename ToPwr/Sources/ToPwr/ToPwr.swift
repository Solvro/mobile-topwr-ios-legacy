import ComposableArchitecture
import SplashFeature
import CoreLogic
import Common
import Combine
import Foundation

private let coreLogic: CoreLogic = CoreLogic()

private let store = Store(initialState: Splash.State(), reducer: Splash())

public let splashView: SplashView = SplashView(store: store)
