//
//  InfoLiveKey.swift
//  
//
//  Created by Mikolaj Zawada on 14/07/2023.
//

import Foundation
import Common
import ComposableArchitecture
import InfoFeature
import CoreLogic

extension DependencyValues.InfoKey: DependencyKey {
    public static var liveValue: InfoEnvironment = .init { start in
        try await CoreLogic().getInfos(startingFrom: start).async()
    } getAboutUs: {
        try await CoreLogic().getAboutUs().async()
    }

}
