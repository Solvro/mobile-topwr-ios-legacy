import SwiftUI
import ComposableArchitecture
import Combine
import Common
import DepartmentsFeature
import ClubsFeature
import WhatsNewFeature

//MARK: - STATE
public struct HomeState: Equatable {
    var whatsNewListState = WhatsNewListState()
    var departmentListState = DepartmentHomeListState()
    var buildingListState = BuildingListState()
    var clubHomeListState = ClubHomeListState()
    var exceptations: ExceptationDays?
    var sessionDay: SessionDay? = nil

    public init(){}
}
//MARK: - ACTION
public enum HomeAction: Equatable {
    case onAppear
    case onDisappear
    case loadApiData
    case loadSessionDate
    case loadDepartments
    case loadBuildings
    case loadScienceClubs
    case loadWelcomeDayText
    case loadWhatsNew
    case receivedSessionDate(Result<SessionDay, ErrorModel>)
    case receivedDepartments(Result<[Department], ErrorModel>)
    case receivedBuildings(Result<[Map], ErrorModel>)
    case receivedScienceClubs(Result<[ScienceClub], ErrorModel>)
    case receivedWelcomeDayText(Result<ExceptationDays, ErrorModel>)
    case receivedNews(Result<[WhatsNew], ErrorModel>)
    case buttonTapped
    case whatsNewListAction(WhatsNewListAction)
    case departmentListAction(DepartmentHomeListAction)
    case buildingListAction(BuildingListAction)
    case clubHomeListAction(ClubHomeListAction)
}

//MARK: - ENVIRONMENT
public struct HomeEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getSessionDate: () -> AnyPublisher<SessionDay, ErrorModel>
    let getDepartments: () -> AnyPublisher<[Department], ErrorModel>
    let getDepartment: (Int) -> AnyPublisher<Department, ErrorModel>
    let getBuildings: () -> AnyPublisher<[Map], ErrorModel>
    let getScienceClubs: (Int) -> AnyPublisher<[ScienceClub], ErrorModel>
    let getScienceClub: (Int) -> AnyPublisher<ScienceClub, ErrorModel>
    let getWelcomeDayText: () -> AnyPublisher<ExceptationDays, ErrorModel>
    let getWhatsNew: () -> AnyPublisher<[WhatsNew], ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getSessionDate: @escaping () -> AnyPublisher<SessionDay, ErrorModel>,
        getDepartments: @escaping () -> AnyPublisher<[Department], ErrorModel>,
        getDepartment: @escaping (Int) -> AnyPublisher<Department, ErrorModel>,
        getBuildings: @escaping () -> AnyPublisher<[Map], ErrorModel>,
        getScienceClubs: @escaping (Int) -> AnyPublisher<[ScienceClub], ErrorModel>,
        getScienceClub: @escaping (Int) -> AnyPublisher<ScienceClub, ErrorModel>,
        getWelcomeDayText: @escaping () -> AnyPublisher<ExceptationDays, ErrorModel>,
        getWhatsNew: @escaping () -> AnyPublisher<[WhatsNew], ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getSessionDate = getSessionDate
        self.getDepartments = getDepartments
        self.getDepartment = getDepartment
        self.getBuildings = getBuildings
        self.getScienceClubs = getScienceClubs
        self.getScienceClub = getScienceClub
        self.getWelcomeDayText = getWelcomeDayText
        self.getWhatsNew = getWhatsNew
    }
}

//MARK: - REDUCER
public let homeReducer = Reducer<
    HomeState,
    HomeAction,
    HomeEnvironment
> { state, action, env in
  switch action {
  case .onAppear:
      if state.sessionDay == nil {
          return .init(value: .loadApiData)
      } else {
          return .none
      }
  case .onDisappear:
      return .none
      
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
      return env.getSessionDate()
          .receive(on: env.mainQueue)
          .catchToEffect()
          .map(HomeAction.receivedSessionDate)
  case .loadDepartments:
      return env.getDepartments()
          .receive(on: env.mainQueue)
          .catchToEffect()
          .map(HomeAction.receivedDepartments)
  case .loadBuildings:
      return env.getBuildings()
          .receive(on: env.mainQueue)
          .catchToEffect()
          .map(HomeAction.receivedBuildings)
  case .loadScienceClubs:
      return env.getScienceClubs(0)
          .receive(on: env.mainQueue)
          .catchToEffect()
          .map(HomeAction.receivedScienceClubs)
  case .loadWelcomeDayText:
      return env.getWelcomeDayText()
          .receive(on: env.mainQueue)
          .catchToEffect()
          .map(HomeAction.receivedWelcomeDayText)
      
      //api success
  case .loadWhatsNew:
      return env.getWhatsNew()
          .receive(on: env.mainQueue)
          .catchToEffect()
          .map(HomeAction.receivedNews)
  case .receivedSessionDate(.success(let sessionDate)):
      state.sessionDay = sessionDate
      return .none
  case .receivedDepartments(.success(let departments)):
      state.departmentListState = .init(
        departments: departments.map {
            DepartmentDetailsState(department: $0)
        }
      )
      return .none
  case .receivedBuildings(.success(let buildings)):
      state.buildingListState = .init(
        buildings: buildings.map {
            BuildingCellState(building: $0)
        }
      )
      return .none
  case .receivedScienceClubs(.success(let clubs)):
      state.clubHomeListState = .init(
        clubs: clubs.map {
            ClubDetailsState(club: $0)
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
.combined(
    with: departmentHomeListReducer
        .pullback(
            state: \.departmentListState,
            action: /HomeAction.departmentListAction,
            environment: {
                .init(
                    mainQueue: $0.mainQueue,
                    getScienceClub: $0.getScienceClub
                )
            }
        )
)
.combined(
    with: buildingListReducer
        .pullback(
            state: \.buildingListState,
            action: /HomeAction.buildingListAction,
            environment: { env in
                    .init(mainQueue: env.mainQueue)
            }
        )
)
.combined(
    with: clubHomeListReducer
        .pullback(
            state: \.clubHomeListState,
            action: /HomeAction.clubHomeListAction,
            environment: {
                .init(
                    mainQueue: $0.mainQueue,
                    getDepartment: $0.getDepartment
                )
            }
        )
)
.combined(
    with: whatsNewListReducer
        .pullback(
            state: \.whatsNewListState,
            action: /HomeAction.whatsNewListAction,
            environment: {
                .init(mainQueue: $0.mainQueue)
            }
        )
)

//MARK: - VIEW
public struct HomeView: View {
    let store: Store<HomeState, HomeAction>
    
    public init(
        store: Store<HomeState, HomeAction>
    ) {
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
                            .verticalPadding(.big)
                            .horizontalPadding(.normal)
                        
                        DaysToSessionView(session: viewStore.sessionDay)
                            .horizontalPadding(.normal)
                        
                        /// Whats New
                        WhatsNewListView(
                            store:  self.store.scope(
                                state: \.whatsNewListState,
                                action: HomeAction.whatsNewListAction
                            )
                        )
                        
                        /// Buildings
                        BuildingListView(
                            store:  self.store.scope(
                                state: \.buildingListState,
                                action: HomeAction.buildingListAction
                            )
                        )
                        
                        // Science Clubs
                        ClubHomeListView(
                            store: self.store.scope(
                                state: \.clubHomeListState,
                                action: HomeAction.clubHomeListAction
                            )
                        )
                        
                        /// Departments
                        DepartmentHomeListView(
                            store: self.store.scope(
                                state: \.departmentListState,
                                action: HomeAction.departmentListAction
                            )
                        )
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .barLogo()
            }
        }
    }
}

//MARK: - MOCKS & PREVIEW
#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            store: Store(
                initialState: .init(),
                reducer: homeReducer,
                environment: .failing
            )
        )
    }
}

public extension HomeEnvironment {
    static let failing: Self = .init(
        mainQueue: .immediate,
        getSessionDate: failing0,
        getDepartments: failing0,
        getDepartment: failing1,
        getBuildings: failing0,
        getScienceClubs: failing1,
        getScienceClub: failing1,
        getWelcomeDayText: failing0,
        getWhatsNew: failing0
    )
}
#endif
