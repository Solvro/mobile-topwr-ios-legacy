//
//  MapBuildingsLiveKey.swift
//
//
//  Created by Aleksandra Generowicz on 17/07/2023.
//

import Foundation
import Common
import ComposableArchitecture
import MapFeature
import CoreLogic

extension DependencyValues.MapBuildingsKey: DependencyKey {
    public static var liveValue: MapBuildingsEnvironment = .init {
        try await CoreLogic().getBuildings().async()
    }
}
