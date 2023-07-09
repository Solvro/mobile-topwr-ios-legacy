//
//  HomeEnvironment.swift
//  
//
//  Created by Mikolaj Zawada on 09/07/2023.
//

import Foundation
import Dependencies
import XCTestDynamicOverlay
import Common

public struct HomeEnvironment {
    var getSessionDate: () async throws -> SessionDay
    var getDepartments: (Int) async throws -> [Department]
    var getBuildings: () async throws -> [Map]
    var getScienceClubs: (Int) async throws -> [ScienceClub]
    var getWelcomeDayText: () async throws -> ExceptationDays
    var getWhatsNew: () async throws -> [WhatsNew]
    
    public init(
        getSessionDate: @escaping () async throws -> SessionDay,
        getDepartments: @escaping (Int) async throws -> [Department],
        getBuildings: @escaping () async throws -> [Map],
        getScienceClubs: @escaping (Int) async throws -> [ScienceClub],
        getWelcomeDayText: @escaping () async throws -> ExceptationDays,
        getWhatsNew: @escaping () async throws -> [WhatsNew]
    ) {
        self.getSessionDate = getSessionDate
        self.getDepartments = getDepartments
        self.getBuildings = getBuildings
        self.getScienceClubs = getScienceClubs
        self.getWelcomeDayText = getWelcomeDayText
        self.getWhatsNew = getWhatsNew
    }
}

public extension DependencyValues {
    var home: HomeEnvironment {
        get { self[HomeKey.self] }
        set { self[HomeKey.self] = newValue }
    }

    enum HomeKey: TestDependencyKey {
        public static var testValue: HomeEnvironment = .init(
            getSessionDate: XCTUnimplemented("Get session day"),
            getDepartments: XCTUnimplemented("Get departments"),
            getBuildings: XCTUnimplemented("Get buildings"),
            getScienceClubs: XCTUnimplemented("Get scienceClubs"),
            getWelcomeDayText: XCTUnimplemented("Get welcome day text"),
            getWhatsNew: XCTUnimplemented("Get whats new")
        )

#if DEBUG

        // TODO: - Implement preview val
#endif
    }
}
