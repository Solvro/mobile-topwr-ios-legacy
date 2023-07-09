//
//  HomeLiveKey.swift
//  
//
//  Created by Mikolaj Zawada on 09/07/2023.
//

import Foundation
import Common
import ComposableArchitecture
import HomeFeature
import CoreLogic

extension DependencyValues.HomeKey: DependencyKey {
    public static var liveValue: HomeEnvironment = .init {
        try await CoreLogic().getSessionDate().async()
    } getDepartments: { start in
        try await CoreLogic().getDepartments(startingFrom: start).async()
    } getBuildings: {
        try await CoreLogic().getBuildings().async()
    } getScienceClubs: { start in
        try await CoreLogic().getScienceClubs(startingFrom: start).async()
    } getWelcomeDayText: {
        try await CoreLogic().getWelcomeDayText().async()
    } getWhatsNew: {
        try await CoreLogic().getWhatsNew().async()
    }
}
