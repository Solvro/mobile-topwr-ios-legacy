//
//  DepartmentEnvironment.swift
//  
//
//  Created by Mikolaj Zawada on 14/07/2023.
//

import Foundation
import Dependencies
import XCTestDynamicOverlay
import Common

public struct DepartmentsEnvironment {
    var getDepartments: (Int) async throws -> [Department]
    var getScienceClub: (Int) async throws -> ScienceClub
    
    public init(
        getDepartments: @escaping (Int) async throws -> [Department],
        getScienceClub: @escaping (Int) async throws -> ScienceClub
    ) {
        self.getDepartments = getDepartments
        self.getScienceClub = getScienceClub
    }
}

public extension DependencyValues {
    var departments: DepartmentsEnvironment {
        get { self[DepartmentsKey.self] }
        set { self[DepartmentsKey.self] = newValue }
    }
    
    enum DepartmentsKey: TestDependencyKey {
        public static var testValue: DepartmentsEnvironment = .init(
            getDepartments: XCTUnimplemented("Get departments"),
            getScienceClub: XCTUnimplemented("Get scienceClub")
        )
    }
    
#if DEBUG
        // TODO: - Implement preview val
#endif
}
