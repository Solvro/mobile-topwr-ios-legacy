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
    var getDepartment: (Int) async throws -> Department
    var getAllScienceClubs: () async throws -> [ScienceClub]
    
    public init(
        getScienceClubs: @escaping (Int) async throws -> [ScienceClub],
        getDepartment: @escaping (Int) async throws -> Department,
        getAllScienceClubs: @escaping () async throws -> [ScienceClub]
    ) {
        self.getScienceClubs = getScienceClubs
        self.getDepartment = getDepartment
        self.getAllScienceClubs = getAllScienceClubs
    }
}

public extension DependencyValues {
    var clubs: ClubsEnvironment {
        get { self[ClubsKey.self] }
        set { self[ClubsKey.self] = newValue }
    }
    
    enum ClubsKey: TestDependencyKey {
        public static var testValue: ClubsEnvironment = .init(
            getScienceClubs: XCTUnimplemented("Get scienceClubs"),
            getDepartment: XCTUnimplemented("Get department"),
            getAllScienceClubs: XCTUnimplemented("Get all science clubs")
        )
#if DEBUG
        // TODO: - Implement preview val
#endif
    }
}
