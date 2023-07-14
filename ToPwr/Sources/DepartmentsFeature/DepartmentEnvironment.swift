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
    
    public init(
        getDepartments: @escaping (Int) async throws -> [Department]
    ) {
        self.getDepartments = getDepartments
    }
}

public extension DependencyValues {
    var departments: DepartmentsEnvironment {
        get { self[DepartmentsKey.self] }
        set { self[DepartmentsKey.self] = newValue }
    }
    
    enum DepartmentsKey: TestDependencyKey {
        public static var testValue: DepartmentsEnvironment = .init(
            getDepartments: XCTUnimplemented("Get departments")
        )
    }
    
#if DEBUG
        // TODO: - Implement preview val
#endif
}
