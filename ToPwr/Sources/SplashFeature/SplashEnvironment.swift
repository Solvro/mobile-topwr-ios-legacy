//
//  SplashEnvironment.swift
//  
//
//  Created by Mikolaj Zawada on 10/07/2023.
//

import Foundation
import Dependencies
import Common
import XCTestDynamicOverlay

public struct SplashEnvironment {
    var getApiVersion: () async throws -> Version
    
    public init(
        getApiVersion: @escaping () async throws -> Version
    ) {
        self.getApiVersion = getApiVersion
    }
}

public extension DependencyValues {
    var splash: SplashEnvironment {
        get { self[SplashKey.self] }
        set { self[SplashKey.self] = newValue }
    }
    
    enum SplashKey: TestDependencyKey {
        public static var testValue: SplashEnvironment = .init(
            getApiVersion: XCTUnimplemented("Get api version")
        )
    }
}
