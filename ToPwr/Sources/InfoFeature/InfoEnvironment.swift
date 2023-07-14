//
//  InfoEnvironment.swift
//  
//
//  Created by Mikolaj Zawada on 14/07/2023.
//

import Foundation
import Dependencies
import XCTestDynamicOverlay
import Common

public struct InfoEnvironment {
    var getInfos: (Int) async throws -> [Info]
    var getAboutUs: () async throws -> AboutUs
    
    public init(
        getInfos: @escaping (Int) async throws -> [Info],
        getAboutUs: @escaping () async throws -> AboutUs
    ) {
        self.getInfos = getInfos
        self.getAboutUs = getAboutUs
    }
}

public extension DependencyValues {
    var info: InfoEnvironment {
        get { self[InfoKey.self] }
        set { self[InfoKey.self] = newValue }
    }
    
    enum InfoKey: TestDependencyKey {
        public static var testValue: InfoEnvironment = .init(
            getInfos: XCTUnimplemented("Get infos"),
            getAboutUs: XCTUnimplemented("Get about us")
        )
    }
    
#if DEBUG
        // TODO: - Implement preview val
#endif
}
