//
//  DepartmentsLiveKey.swift
//  
//
//  Created by Mikolaj Zawada on 14/07/2023.
//

import Foundation
import Common
import ComposableArchitecture
import DepartmentsFeature
import CoreLogic

extension DependencyValues.DepartmentsKey: DependencyKey {
    public static var liveValue: DepartmentsEnvironment = .init { value in
        try await CoreLogic().getDepartments(startingFrom: value).async()
    }
}
