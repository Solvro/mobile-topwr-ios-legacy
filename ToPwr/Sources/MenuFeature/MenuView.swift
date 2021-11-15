import SwiftUI
import ComposableArchitecture
import Combine
import HomeFeature
import MapFeature
import DepartmentsFeature
import ClubsFeature
import InfoFeature
import Common
import Strings

//MARK: - STATE
public struct MenuState: Equatable {
    var homeState = HomeState()
    var mapState = MapFeatureState()
    var departmentsState = DepartmentsState()
    var clubsState = ClubsState()
    var infoState = InfoState()
    
    public init(){}
}

//MARK: - ACTION
public enum MenuAction: Equatable, BindableAction {
    case homeAction(HomeAction)
    case mapAction(MapFeatureAction)
    case departmentsAction(DepartmentsAction)
    case clubsAction(ClubsAction)
    case infoAction(InfoAction)
    case binding(BindingAction<MenuState>)
}

//MARK: - ENVIRONMENT
public struct MenuEnvironment {
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
public let menuReducer = Reducer<
    MenuState,
    MenuAction,
    MenuEnvironment
> { state, action, environment in
    switch action {
    case .homeAction:
        return .none
    case .mapAction:
        return .none
    case .departmentsAction:
        return .none
    case .clubsAction:
        return .none
    case .infoAction:
        return .none
    case .binding:
        return .none
    }
}
.binding()
.combined(
    with: homeReducer
        .pullback(
            state: \.homeState,
            action: /MenuAction.homeAction,
            environment: { env in
                    .init(
                        mainQueue: env.mainQueue,
                        getSessionDate: env.getSessionDate,
                        getDepartments: env.getDepartments,
                        getBuildings: env.getBuildings,
                        getScienceClubs: env.getScienceClubs
                    )
            }
        )
)
.combined(
    with: mapFeatureReducer
        .pullback(
            state: \.mapState,
            action: /MenuAction.mapAction,
            environment: { env in
                    .init(mainQueue: env.mainQueue)
            }
        )
)
.combined(
    with: DepartmentsReducer
        .pullback(
            state: \.departmentsState,
            action: /MenuAction.departmentsAction,
            environment: { env in
                    .init(
                        mainQueue: env.mainQueue,
                        getDepartments: env.getDepartments
                    )
            }
        )
)
.combined(
    with: ClubsReducer
        .pullback(
            state: \.clubsState,
            action: /MenuAction.clubsAction,
            environment: { env in
                    .init(mainQueue: env.mainQueue,
                          getClubs: env.getScienceClubs)
            }
        )
)
.combined(
    with: infoReducer
        .pullback(
            state: \.infoState,
            action: /MenuAction.infoAction,
            environment: { env in
                    .init(mainQueue: env.mainQueue)
            }
        )
)
//MARK: - VIEW
public struct MenuView: View {
    let store: Store<MenuState, MenuAction>
    
    public init(
        store: Store<MenuState, MenuAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        TabView {
            HomeView(
                store: self.store.scope(
                    state: \.homeState,
                    action: MenuAction.homeAction
                )
            )
                .tabItem {
                    Image(systemName: "house.fill")
                    Strings.TabBar.home
                }
            
            MapFeatureView(
                store: self.store.scope(
                    state: \.mapState,
                    action: MenuAction.mapAction
                )
            )
                .tabItem {
                    Image(systemName: "map.fill")
                    Strings.TabBar.map
                }
            
            DepartmentsView(
                store: self.store.scope(
                    state: \.departmentsState,
                    action: MenuAction.departmentsAction
                )
            )
                .tabItem {
                    Image(systemName: "arrowshape.turn.up.left.circle.fill")
                    Strings.TabBar.faculties
                }
            
            ClubsView(
                store: self.store.scope(
                    state: \.clubsState,
                    action: MenuAction.clubsAction
                )
            )
                .tabItem {
                    Image(systemName: "suit.club.fill")
                    Strings.TabBar.clubs
                }
            InfoView(
                store: self.store.scope(
                    state: \.infoState,
                    action: MenuAction.infoAction
                )
            )
                .tabItem {
                    Image(systemName: "info.circle.fill")
                    Strings.TabBar.calculator
                }
        }
        .accentColor(K.Colors.firstColorDark)
    }
}

//MARK: - MOCKS & PREVIEW
#if DEBUG
struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(
            store: Store(
                initialState: .init(),
                reducer: menuReducer,
                environment: .init(
                    mainQueue: .immediate,
                    getSessionDate: failing0,
                    getDepartments: failing0,
                    getBuildings: failing0,
                    getScienceClubs: failing0
                )
            )
        )
    }
}
#endif
