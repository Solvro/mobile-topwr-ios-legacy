import SwiftUI
import ComposableArchitecture
import Combine
import HomeFeature
import MapFeature
import FacultiesFeature
import ClubsFeature
import InfoFeature
import Common

//MARK: - STATE
public struct MenuState: Equatable {
    var homeState = HomeState()
    var mapState = MapState()
    var facultiesState = FacultiesState()
    var clubsState = ClubsState()
    var infoState = InfoState()
    
    public init(){}
}

//MARK: - ACTION
public enum MenuAction: Equatable, BindableAction {
    case homeAction(HomeAction)
    case mapAction(MapAction)
    case facultiesAction(FacultiesAction)
    case clubsAction(ClubsAction)
    case infoAction(InfoAction)
    case binding(BindingAction<MenuState>)
}

//MARK: - ENVIRONMENT
public struct MenuEnvironment {
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
    case .facultiesAction:
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
                        getSessionDate: env.getSessionDate
                    )
            }
        )
)
.combined(
    with: mapReducer
        .pullback(
            state: \.mapState,
            action: /MenuAction.mapAction,
            environment: { env in
                    .init(mainQueue: env.mainQueue)
            }
        )
)
.combined(
    with: facultiesReducer
        .pullback(
            state: \.facultiesState,
            action: /MenuAction.facultiesAction,
            environment: { env in
                    .init(mainQueue: env.mainQueue)
            }
        )
)
.combined(
    with: clubsReducer
        .pullback(
            state: \.clubsState,
            action: /MenuAction.clubsAction,
            environment: { env in
                    .init(mainQueue: env.mainQueue)
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
                    Text("Home")
                }
            
            MapView(
                store: self.store.scope(
                    state: \.mapState,
                    action: MenuAction.mapAction
                )
            )
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
            
            FacultiesView(
                store: self.store.scope(
                    state: \.facultiesState,
                    action: MenuAction.facultiesAction
                )
            )
                .tabItem {
                    Image(systemName: "arrowshape.turn.up.left.circle.fill")
                    Text("Faculties")
                }
            
            ClubsView(
                store: self.store.scope(
                    state: \.clubsState,
                    action: MenuAction.clubsAction
                )
            )
                .tabItem {
                    Image(systemName: "suit.club.fill")
                    Text("Clubs")
                }
            InfoView(
                store: self.store.scope(
                    state: \.infoState,
                    action: MenuAction.infoAction
                )
            )
                .tabItem {
                    Image(systemName: "info.circle.fill")
                    Text("Calculator")
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
                    getSessionDate: failing0
                )
            )
        )
    }
}
#endif
