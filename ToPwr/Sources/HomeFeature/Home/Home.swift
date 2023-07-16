//
//  Home.swift
//  
//
//  Created by Mikolaj Zawada on 16/07/2023.
//

import Foundation
import ComposableArchitecture
import DepartmentsFeature
import WhatsNewFeature
import ClubsFeature
import Common

public struct Home: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        
        var destinations = StackState<Destinations.State>()
        
        var whatsNewListState = WhatsNewListFeature.State()
        var departmentListState = DepartmentHomeList.State()
        var buildingListState = BuildingList.State()
        var clubHomeListState = ClubHomeList.State()
        var exceptations: ExceptationDays?
        var sessionDay: SessionDay? = nil

        public init(){}
    }
    
    public init() {}
    
    // MARK: - Action
    public enum Action: Equatable {
        case onAppear
        case onAppCameToForeground
        case loadApiData
        case loadSessionDate
        case loadDepartments
        case loadBuildings
        case loadScienceClubs
        case loadWelcomeDayText
        case loadWhatsNew
        // TODO: - Use task result
        case receivedSessionDate(TaskResult<SessionDay>)
        case receivedDepartments(TaskResult<[Department]>)
        case receivedBuildings(TaskResult<[Map]>)
        case receivedScienceClubs(TaskResult<[ScienceClub]>)
        case receivedWelcomeDayText(TaskResult<ExceptationDays>)
        case receivedNews(TaskResult<[WhatsNew]>)
        case buttonTapped
        case whatsNewListAction(WhatsNewListFeature.Action)
        case departmentListAction(DepartmentHomeList.Action)
        case buildingListAction(BuildingList.Action)
        case clubHomeListAction(ClubHomeList.Action)
        case destinations(StackAction<Destinations.State, Destinations.Action>)
    }
    
    // MARK: - Dependencies
    @Dependency(\.home) var homeClient
    
    // MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        
        Scope(
            state: \.departmentListState,
            action: /Action.departmentListAction
        ) { () -> DepartmentHomeList in
            DepartmentHomeList()
        }
        
        Scope(
            state: \.buildingListState,
            action: /Action.buildingListAction
        ) { () -> BuildingList in
            BuildingList()
        }
        
        Scope(
            state: \.clubHomeListState,
            action: /Action.clubHomeListAction
        ) { () -> ClubHomeList in
            ClubHomeList()
        }
        
        Scope(
            state: \.whatsNewListState,
            action: /Action.whatsNewListAction
        ) { () -> WhatsNewListFeature in
            WhatsNewListFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.sessionDay == nil {
                    return .task { .loadApiData }
                } else {
                    return .none
                }
            case .onAppCameToForeground:
                return .task { .loadApiData }
                //api load
            case .loadApiData:
                return .run { send in
                    await send(.loadWhatsNew)
                    await send(.loadSessionDate)
                    await send(.loadDepartments)
                    await send(.loadBuildings)
                    await send(.loadScienceClubs)
                    await send(.loadWelcomeDayText)
                }
            case .loadSessionDate:
                return .task {
                    await .receivedSessionDate(TaskResult {
                        try await homeClient.getSessionDate()
                    })
                }
            case .loadDepartments:
                return .task {
                    await .receivedDepartments(TaskResult {
                        // FIXME: - Should this be hardcoded?
                        try await homeClient.getDepartments(0)
                    })
                }
            case .loadBuildings:
                return .task {
                    await .receivedBuildings(TaskResult {
                        try await homeClient.getBuildings()
                    })
                }
            case .loadScienceClubs:
                return .task {
                    await .receivedScienceClubs(TaskResult {
                        try await homeClient.getScienceClubs(0)
                    })
                }
            case .loadWelcomeDayText:
                return .task {
                    await .receivedWelcomeDayText(TaskResult {
                        try await homeClient.getWelcomeDayText()
                    })
                }
            case .loadWhatsNew:
                return .task {
                    await .receivedNews(TaskResult {
                        try await homeClient.getWhatsNew()
                    })
                }
            case .receivedSessionDate(.success(let sessionDate)):
                state.sessionDay = sessionDate
                return .none
            case .receivedDepartments(.success(let departments)):
                let sortedDepartments = departments.sorted(by: { $0.id < $1.id})
                state.departmentListState = .init(
                  departments: sortedDepartments.map {
                      DepartmentDetails.State(department: $0)
                  }
                )
                return .none
            case .receivedBuildings(.success(let buildings)):
                state.buildingListState = .init(
                  buildings: buildings.map {
                      BuildingCell.State(building: $0)
                  }
                )
                return .none
            case .receivedScienceClubs(.success(let clubs)):
                state.clubHomeListState = .init(
                  clubs: clubs.map {
                      ClubDetails.State(club: $0)
                  }
                )
                return .none
            case .receivedWelcomeDayText(.success(let exceptations)):
                state.exceptations = exceptations
                return .none
            case .receivedNews(.success(let news)):
                state.whatsNewListState = .init(news: news)
                return .none
            case .receivedSessionDate(.failure),
                    .receivedDepartments(.failure),
                    .receivedBuildings(.failure),
                    .receivedScienceClubs(.failure),
                    .receivedNews(.failure):
                return .none
            case .receivedWelcomeDayText(.failure):
                return .none
            case .buttonTapped:
              return .none
            case .whatsNewListAction(.navigateToDetails(let navState)):
                state.destinations.append(.whatsNewDetails(navState))
                return .none
            case .whatsNewListAction:
                return .none
            case .departmentListAction(.navigateToDetails(let navState)):
                state.destinations.append(.departmentDetails(navState))
                return .none
            case .departmentListAction:
                return .none
            case .buildingListAction:
                return .none
            case .clubHomeListAction(.navigateToDetails(let navState)):
                state.destinations.append(.club(navState))
                return .none
            case .clubHomeListAction:
                return .none
            case .destinations:
                return .none
            }
        }
        .forEach(\.destinations, action: /Action.destinations) {
            Destinations()
        }
    }
    
    public struct Destinations: ReducerProtocol {
        
        public enum State: Equatable {
            case whatsNewDetails(WhatsNewDetailsFeature.State)
            case club(ClubDetails.State)
            case departmentDetails(DepartmentDetails.State)
        }
        
        public enum Action: Equatable {
            case whatsNewDetails(WhatsNewDetailsFeature.Action)
            case club(ClubDetails.Action)
            case departmentDetails(DepartmentDetails.Action)
        }
        
        public var body: some ReducerProtocol<State,Action> {
            EmptyReducer()
                .ifCaseLet(
                    /State.whatsNewDetails,
                     action: /Action.whatsNewDetails
                ) {
                    WhatsNewDetailsFeature()
                }
                .ifCaseLet(
                    /State.club,
                     action: /Action.club
                ) {
                    ClubDetails()
                }
                .ifCaseLet(
                    /State.departmentDetails,
                     action: /Action.departmentDetails
                ) {
                    DepartmentDetails()
                }
        }
    }
}

#if DEBUG

// MARK: - Mock
extension Home.State {
    static let mock: Self = .init()
}

#endif
