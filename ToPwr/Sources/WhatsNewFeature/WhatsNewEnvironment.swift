//
//  WhatsNewEnvironment.swift
//  
//
//  Created by Mikolaj Zawada on 25/07/2023.
//

import Foundation
import Dependencies
import XCTestDynamicOverlay
import Common

public struct WhatsNewEnvironment {
    var getWhatsNewDetails: (URL) async throws -> [NewsComponent]
    
    public init(
        getWhatsNewDetails: @escaping (URL) async throws -> [NewsComponent]
    ) {
        self.getWhatsNewDetails = getWhatsNewDetails
    }
}

public extension DependencyValues {
    var news: WhatsNewEnvironment {
        get { self[NewsKey.self] }
        set { self[NewsKey.self] = newValue }
    }
    
    enum NewsKey: TestDependencyKey {
        public static var testValue: WhatsNewEnvironment = .init(
            getWhatsNewDetails: XCTUnimplemented("Get news details")
        )
    }
}
