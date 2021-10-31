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
    case receivedSessionDate(Result<SessionDay, ErrorModel>)
    case buttonTapped
    case departmentListAction(DepartmentListAction)
    case buildingListAction(BuildingListAction)
    case scienceClubListAction(ScienceClubListAction)
}

//MARK: - ENVIRONMENT
public struct HomeEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var getSessionDate: () -> AnyPublisher<SessionDay, ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getSessionDate: @escaping () -> AnyPublisher<SessionDay, ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getSessionDate = getSessionDate
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
          return env.getSessionDate()
              .receive(on: env.mainQueue)
              .catchToEffect()
              .map(HomeAction.receivedSessionDate)
      } else {
          return .none
      }
  case .onDisappear:
      return .none
  case .receivedSessionDate(.success(let sessionDate)):
      state.sessionDay = sessionDate
      return .none
  case .receivedSessionDate(.failure):
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
            ScrollView {
                VStack(alignment: .leading) {
                    ZStack {
                        //Logo View - TODO
                        HStack {
                            Text("#")
                                .foregroundColor(K.Colors.firstColorDark)
                                .fontWeight(.bold)
                            Text("TO")
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                            Text("PWR")
                                .foregroundColor(K.Colors.firstColorDark)
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .padding([.top, .bottom], 35)
                    
                    HStack {
                        WelcomeView()
                        Spacer()
                    }
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
                    }
                }
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
            .padding(.leading)
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
        getSessionDate: failing0
    )
}
#endif
