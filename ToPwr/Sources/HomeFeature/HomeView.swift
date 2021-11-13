import SwiftUI
import ComposableArchitecture
import Combine
import Common
import CellsFeature
import CryptoKit

//MARK: - STATE
public struct HomeState: Equatable {
    var text: String = "Hello World ToPwr"
    
    var departmentListState = DepartmentListState()
    var buildingListState = BuildingListState()
    var scienceClubListState = ScienceClubListState()
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
    case receivedSessionDate(Result<SessionDay, ErrorModel>)
    case receivedDepartments(Result<[Department], ErrorModel>)
    case receivedBuildings(Result<[Map], ErrorModel>)
    case receivedScienceClubs(Result<[ScienceClub], ErrorModel>)
    case buttonTapped
    case departmentListAction(DepartmentListAction)
    case buildingListAction(BuildingListAction)
    case scienceClubListAction(ScienceClubListAction)
}

//MARK: - ENVIRONMENT
public struct HomeEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var getSessionDate: () -> AnyPublisher<SessionDay, ErrorModel>
    var getDepartments: () -> AnyPublisher<[Department], ErrorModel>
    var getBuildings: () -> AnyPublisher<[Map], ErrorModel>
    var getScienceClubs: () -> AnyPublisher<[ScienceClub], ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getSessionDate: @escaping () -> AnyPublisher<SessionDay, ErrorModel>,
        getDepartments: @escaping () -> AnyPublisher<[Department], ErrorModel>,
        getBuildings: @escaping () -> AnyPublisher<[Map], ErrorModel>,
        getScienceClubs: @escaping () -> AnyPublisher<[ScienceClub], ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getSessionDate = getSessionDate
        self.getDepartments = getDepartments
        self.getBuildings = getBuildings
        self.getScienceClubs = getScienceClubs
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
        .init(value: .loadSessionDate),
        .init(value: .loadDepartments),
        .init(value: .loadBuildings),
        .init(value: .loadScienceClubs)
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
      return env.getScienceClubs()
          .receive(on: env.mainQueue)
          .catchToEffect()
          .map(HomeAction.receivedScienceClubs)
      
      //api success
  case .receivedSessionDate(.success(let sessionDate)):
      state.sessionDay = sessionDate
      return .none
  case .receivedDepartments(.success(let departments)):
      state.departmentListState = .init(
        departments: departments.map {
            DepartmentCellState(department: $0)
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
      state.scienceClubListState = .init(
        scienceClubs: clubs.map {
            ScienceClubCellState(scienceClub: $0)
        }
      )
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
  case .buttonTapped:
    return .none
  case .departmentListAction:
      return .none
  case .buildingListAction:
      return .none
  case .scienceClubListAction:
      return .none
  }
}
.combined(
    with: departmentListReducer
        .pullback(
            state: \.departmentListState,
            action: /HomeAction.departmentListAction,
            environment: { env in
                    .init(mainQueue: env.mainQueue)
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
    with: scienceClubListReducer
        .pullback(
            state: \.scienceClubListState,
            action: /HomeAction.scienceClubListAction,
            environment: { env in
                    .init(mainQueue: env.mainQueue)
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
                    VStack(alignment: .leading) {
                        WelcomeView()
                        
                        DaysToSessionView(session: viewStore.sessionDay)
                            .padding(.bottom, 30)
                        
                        // OSTATNIO WYSZUKIWANE
                        BuildingListView(
                            store:  self.store.scope(
                                state: \.buildingListState,
                                action: HomeAction.buildingListAction
                            )
                        )
                        
                        // WYDZIAŁY
                        DepartmentListView(
                            store: self.store.scope(
                                state: \.departmentListState,
                                action: HomeAction.departmentListAction
                            )
                        )
                        
                        // SCIENCE CLUBS
                        ScienceClubListView(
                            store: self.store.scope(
                                state: \.scienceClubListState,
                                action: HomeAction.scienceClubListAction
                            )
                        )
                        
                        
                        Text("Co słychać?")
                            .bold()
                            .padding(.leading, 10)
                    }
                    
                }
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            LogoView()
                                .aspectRatio(contentMode: .fit)
                            Spacer()
                        }
                        .frame(height: 30)
                        .padding(.bottom, 5)
                    }
                }
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
        getBuildings: failing0,
        getScienceClubs: failing0
    )
}
#endif
