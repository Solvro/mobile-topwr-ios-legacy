//
//  MapBuildingsEnvironment.swift
//
//
//  Created by Aleksandra Generowicz on 17/07/2023.
//

import Foundation
import Dependencies
import XCTestDynamicOverlay
import Common

public struct MapBuildingsEnvironment {
    var getBuildings: () async throws -> [Map]
    
    public init(getBuildings: @escaping () async throws -> [Map]) {
        self.getBuildings = getBuildings
    }
}

public extension DependencyValues {
    var buildings: MapBuildingsEnvironment {
        get { self[MapBuildingsKey.self] }
        set { self[MapBuildingsKey.self] = newValue }
    }
    
    enum MapBuildingsKey: TestDependencyKey {
        public static var testValue: MapBuildingsEnvironment = .init(
            getBuildings: XCTUnimplemented("Get map buildings")
        )
#if DEBUG
        // TODO: - Implement preview val
#endif
    }
}
