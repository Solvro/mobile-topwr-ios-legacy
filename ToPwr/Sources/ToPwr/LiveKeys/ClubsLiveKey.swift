//
//  ClubsLiveKey.swift
//  
//
//  Created by Mikolaj Zawada on 14/07/2023.
//

import Foundation
import Common
import ComposableArchitecture
import ClubsFeature
import CoreLogic

extension DependencyValues.ClubsKey: DependencyKey {
    public static var liveValue: ClubsEnvironment = .init { start in
        try await CoreLogic().getScienceClubs(startingFrom: start).async()
    } getDepartment: { id in
        try await CoreLogic().getDepartment(id: id).async()
    } getAllScienceClubs: {
        try await CoreLogic().getAllScienceClubs().async()
    }
}
