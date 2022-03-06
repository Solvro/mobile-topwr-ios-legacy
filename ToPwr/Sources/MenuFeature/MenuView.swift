import SwiftUI
import ComposableArchitecture
import Combine
import HomeFeature
import MapFeature
import DepartmentsFeature
import ClubsFeature
import InfoFeature
import Common

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
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getSessionDate: () -> AnyPublisher<SessionDay, ErrorModel>
    let getDepartments: () -> AnyPublisher<[Department], ErrorModel>
    let getBuildings: () -> AnyPublisher<[Map], ErrorModel>
    let getScienceClubs: () -> AnyPublisher<[ScienceClub], ErrorModel>
    let getWelcomeDayText: () -> AnyPublisher<ExceptationDays, ErrorModel>
    let getDepartment: (Int) -> AnyPublisher<Department, ErrorModel>
    let getScienceClub: (Int) -> AnyPublisher<ScienceClub, ErrorModel>
    let getWhatsNew: () -> AnyPublisher<[WhatsNew], ErrorModel>
    let getInfos: () -> AnyPublisher<[Info], ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getSessionDate: @escaping () -> AnyPublisher<SessionDay, ErrorModel>,
        getDepartments: @escaping () -> AnyPublisher<[Department], ErrorModel>,
        getBuildings: @escaping () -> AnyPublisher<[Map], ErrorModel>,
        getScienceClubs: @escaping () -> AnyPublisher<[ScienceClub], ErrorModel>,
        getWelcomeDayText: @escaping () -> AnyPublisher<ExceptationDays, ErrorModel>,
        getDepartment: @escaping (Int) -> AnyPublisher<Department, ErrorModel>,
        getScienceClub: @escaping (Int) -> AnyPublisher<ScienceClub, ErrorModel>,
        getWhatsNew: @escaping () -> AnyPublisher<[WhatsNew], ErrorModel>,
        getInfos: @escaping () -> AnyPublisher<[Info], ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getSessionDate = getSessionDate
        self.getDepartments = getDepartments
        self.getBuildings = getBuildings
        self.getScienceClubs = getScienceClubs
        self.getWelcomeDayText = getWelcomeDayText
        self.getDepartment = getDepartment
        self.getScienceClub = getScienceClub
        self.getWhatsNew = getWhatsNew
        self.getInfos = getInfos
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
                        getDepartment: env.getDepartment,
                        getBuildings: env.getBuildings,
                        getScienceClubs: env.getScienceClubs,
                        getScienceClub: env.getScienceClub,
                        getWelcomeDayText: env.getWelcomeDayText,
                        getWhatsNew: env.getWhatsNew
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
                    .init(getBuildings: env.getBuildings,
                          mainQueue: env.mainQueue)
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
                        getDepartments: env.getDepartments,
                        getScienceClub: env.getScienceClub
                    )
            }
        )
)
.combined(
    with: ClubsReducer
        .pullback(
            state: \.clubsState,
            action: /MenuAction.clubsAction,
            environment: {
                    .init(
                        mainQueue: $0.mainQueue,
                        getClubs: $0.getScienceClubs,
                        getDepartment: $0.getDepartment
                    )
            }
        )
)
.combined(
    with: infoReducer
        .pullback(
            state: \.infoState,
            action: /MenuAction.infoAction,
            environment: { env in
                    .init(
                        mainQueue: env.mainQueue,
                        getInfos: env.getInfos
                    )
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
                .preferredColorScheme(.light)
                .tabItem {
                    Image("SchoolIcon")
                }
            
            MapFeatureView(
                store: self.store.scope(
                    state: \.mapState,
                    action: MenuAction.mapAction
                )
            )
                .preferredColorScheme(.light)
                .tabItem {
                    Image("CompassIcon")
                }
            
            DepartmentsView(
                store: self.store.scope(
                    state: \.departmentsState,
                    action: MenuAction.departmentsAction
                )
            )
                .preferredColorScheme(.light)
                .tabItem {
                    Image("HatIcon")
                }
            
            ClubsView(
                store: self.store.scope(
                    state: \.clubsState,
                    action: MenuAction.clubsAction
                )
            )
                .preferredColorScheme(.light)
                .tabItem {
                    Image("RocketIcon")
                }
            InfoView(
                store: self.store.scope(
                    state: \.infoState,
                    action: MenuAction.infoAction
                )
            )
                .preferredColorScheme(.light)
                .tabItem {
                    Image("InfoIcon")
                }
        }.onAppear(perform: {
            UITabBar.appearance().backgroundColor = .systemBackground
        })
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
                    getScienceClubs: failing0,
                    getWelcomeDayText: failing0,
                    getDepartment: failing1,
                    getScienceClub: failing1,
                    getWhatsNew: failing0,
                    getInfos: failing0
                )
            )
        )
    }
}
#endif
