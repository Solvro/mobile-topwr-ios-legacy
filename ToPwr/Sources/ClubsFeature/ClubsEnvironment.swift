//
//  ClubsEnvironment.swift
//  
//
//  Created by Mikolaj Zawada on 14/07/2023.
//

import Foundation
import Dependencies
import XCTestDynamicOverlay
import Common

public struct ClubsEnvironment {
    var getScienceClubs: (Int) async throws -> [ScienceClub]
    
    public init(
        getScienceClubs: @escaping (Int) async throws -> [ScienceClub]
    ) {
        self.getScienceClubs = getScienceClubs
    }
}

public extension DependencyValues {
    var clubs: ClubsEnvironment {
        get { self[ClubsKey.self] }
        set { self[ClubsKey.self] = newValue }
    }
    
    enum ClubsKey: TestDependencyKey {
        public static var testValue: ClubsEnvironment = .init(
            getScienceClubs: XCTUnimplemented("Get scienceClubs")
        )
#if DEBUG
        // TODO: - Implement preview val
#endif
    }
}
