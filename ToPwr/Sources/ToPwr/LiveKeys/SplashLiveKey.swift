//
//  SplashLiveKey.swift
//  
//
//  Created by Mikolaj Zawada on 10/07/2023.
//

import Foundation
import Common
import Dependencies
import SplashFeature
import CoreLogic

extension DependencyValues.SplashKey: DependencyKey {
    public static var liveValue: SplashEnvironment = .init {
        try await CoreLogic().getApiVersion().async()
    }
}
