import SwiftUI
import ComposableArchitecture
import Combine
import Common
import DepartmentsFeature
import ClubsFeature
import WhatsNewFeature

public struct Home: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        var whatsNewListState = WhatsNewListFeature.State()
        var departmentListState = DepartmentHomeListState()
        public var buildingListState = BuildingList.State()
        var clubHomeListState = ClubHomeList.State()
        var exceptations: ExceptationDays?
        var sessionDay: SessionDay? = nil

        public init(){}
    }
    
    public init() {}
    
    // MARK: - Action
    public enum Action: Equatable {
        case onAppear
        case onDisappear
        case onAppCameToForeground
        case loadApiData
        case loadSessionDate
        case loadDepartments
        case loadBuildings
        case loadScienceClubs
        case loadWelcomeDayText
        case loadWhatsNew
        // TODO: - Use task result
        case receivedSessionDate(Result<SessionDay, ErrorModel>)
        case receivedDepartments(Result<[Department], ErrorModel>)
        case receivedBuildings(Result<[Map], ErrorModel>)
        case receivedScienceClubs(Result<[ScienceClub], ErrorModel>)
        case receivedWelcomeDayText(Result<ExceptationDays, ErrorModel>)
        case receivedNews(Result<[WhatsNew], ErrorModel>)
        case buttonTapped
        case whatsNewListAction(WhatsNewListFeature.Action)
        case departmentListAction(DepartmentHomeListAction)
        case buildingListAction(BuildingList.Action)
        case clubHomeListAction(ClubHomeList.Action)
    }
    
    // MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        
        // TODO: - Scope department list
//        Scope(
//            state: \.departmentListState,
//            action: /Action.departmentListAction
//        ) {
//
//            }
        
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
                    return .init(value: .loadApiData)
                } else {
                    return .none
                }
            case .onDisappear:
                return .none
            case .onAppCameToForeground:
                return .init(value: .loadApiData)
                //api load
            case .loadApiData:
                return .merge(
                  .init(value: .loadWhatsNew),
                  .init(value: .loadSessionDate),
                  .init(value: .loadDepartments),
                  .init(value: .loadBuildings),
                  .init(value: .loadScienceClubs),
                  .init(value: .loadWelcomeDayText)
                )
            case .loadSessionDate:
//                return env.getSessionDate()
//                    .receive(on: env.mainQueue)
//                    .catchToEffect()
//                    .map(HomeAction.receivedSessionDate)
                return .none
            case .loadDepartments:
//                return env.getDepartments(0)
//                    .receive(on: env.mainQueue)
//                    .catchToEffect()
//                    .map(HomeAction.receivedDepartments)
                return .none
            case .loadBuildings:
//                return env.getBuildings()
//                    .receive(on: env.mainQueue)
//                    .catchToEffect()
//                    .map(HomeAction.receivedBuildings)
                return .none
            case .loadScienceClubs:
//                return env.getScienceClubs(0)
//                    .receive(on: env.mainQueue)
//                    .catchToEffect()
//                    .map(HomeAction.receivedScienceClubs)
                return .none
            case .loadWelcomeDayText:
//                return env.getWelcomeDayText()
//                    .receive(on: env.mainQueue)
//                    .catchToEffect()
//                    .map(HomeAction.receivedWelcomeDayText)
                return .none
            case .loadWhatsNew:
//                return env.getWhatsNew()
//                    .receive(on: env.mainQueue)
//                    .catchToEffect()
//                    .map(HomeAction.receivedNews)
                return .none
            case .receivedSessionDate(.success(let sessionDate)):
                state.sessionDay = sessionDate
                return .none
            case .receivedDepartments(.success(let departments)):
                let sortedDepartments = departments.sorted(by: { $0.id < $1.id})
                state.departmentListState = .init(
                  departments: sortedDepartments.map {
                      DepartmentDetailsState(department: $0)
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
            case .receivedSessionDate(.failure(let error)):
                return .none
            case .receivedDepartments(.failure(let error)):
                return .none
            case .receivedBuildings(.failure(let error)):
                return .none
            case .receivedScienceClubs(.failure(let error)):
                print(error)
                return .none
            case .receivedWelcomeDayText(.failure(let error)):
                return .none
            case .receivedNews(.failure(let error)):
                print(error)
                return .none
            case .buttonTapped:
              return .none
            case .whatsNewListAction:
                return .none
            case .departmentListAction:
                return .none
            case .buildingListAction:
                return .none
            case .clubHomeListAction:
                return .none
            }
        }
    }
}

//MARK: - VIEW
public struct HomeView: View {
    let store: StoreOf<Home>
    
    public init(store: StoreOf<Home>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        WelcomeView(
                            exceptations: viewStore.exceptations
                        )
                            .horizontalPadding(.normal)
                        
                        DaysToSessionView(session: viewStore.sessionDay)
                            .horizontalPadding(.normal)
                        
                        /// Whats New
                        WhatsNewListView(
                            store:  store.scope(
                                state: \.whatsNewListState,
                                action: Home.Action.whatsNewListAction
                            )
                        )
                        
                        /// Buildings
                        BuildingListView(
                            store:  store.scope(
                                state: \.buildingListState,
                                action: Home.Action.buildingListAction
                            )
                        )
                        
                        // Science Clubs
                        ClubHomeListView(
                            store: store.scope(
                                state: \.clubHomeListState,
                                action: Home.Action.clubHomeListAction
                            )
                        )
                        
                        /// Departments
                        DepartmentHomeListView(
                            store: store.scope(
                                state: \.departmentListState,
                                action: Home.Action.departmentListAction
                            )
                        )
                    }
                    .padding(.bottom, UIDimensions.normal.size)
                }
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .onAppCameToForeground {
                    viewStore.send(.onAppCameToForeground)
                }
                .barLogo()
            }
        }
    }
}

#if DEBUG
// MARK: - Mock
extension Home.State {
    static let mock: Self = .init()
}

// MARK: - Preview
private struct HomeView_Preview: PreviewProvider {
    static var previews: some View {
        HomeView(
            store: .init(
                initialState: .mock,
                reducer: Home()
            )
        )
    }
}

#endif
