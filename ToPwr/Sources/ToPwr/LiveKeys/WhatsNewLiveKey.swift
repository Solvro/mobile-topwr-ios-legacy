//
//  WhatsNewLiveKey.swift
//  
//
//  Created by Mikolaj Zawada on 25/07/2023.
//

import Foundation
import Common
import Dependencies
import WhatsNewFeature
import CoreLogic

extension DependencyValues.NewsKey: DependencyKey {
    public static var liveValue: WhatsNewEnvironment = .init { url in
        try await NewsWebScrapper.shared.getNewsDetails(url: url)
    }
}
