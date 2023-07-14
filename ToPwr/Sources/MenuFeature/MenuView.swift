import SwiftUI
import ComposableArchitecture
import Combine
import HomeFeature
import MapFeature
import DepartmentsFeature
import ClubsFeature
import InfoFeature
import Common

public struct MenuFeature: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        var homeState = Home.State()
        //var mapState = MapFeatureState()
        var departmentsState = DepartmentFeature.State()
        var clubsState = ClubFeature.State()
        var infoState = InfoFeature.State()
        var selection = 1
        
        public init(){}
    }
    
    public init() {}
    
    // MARK: - Action
    public enum Action: Equatable {
        case homeAction(Home.Action)
        //case mapAction(MapFeatureAction)
        case departmentsAction(DepartmentFeature.Action)
        case clubsAction(ClubFeature.Action)
        case infoAction(InfoFeature.Action)
        case newTabSelection(Int)
    }
    
    // MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        
        Scope(
            state: \.homeState,
            action: /Action.homeAction
        ) { () -> Home in
            Home()
        }
        
        // TODO: - Scope map
        
        Scope(
            state: \.departmentsState,
            action: /Action.departmentsAction
        ) { () -> DepartmentFeature in
            DepartmentFeature()
        }
        
        Scope(
            state: \.clubsState,
            action: /Action.clubsAction
        ) { () -> ClubFeature in
            ClubFeature()
        }
        
        Scope(
            state: \.infoState,
            action: /Action.infoAction
        ) { () -> InfoFeature in
            InfoFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .homeAction(.buildingListAction(.listButtonTapped)):
                state.selection = 2
//                return .task { [delay = state.mapState.bottomSheetOnAppearUpSlideDelay] in
//                    try await environment.mainQueue.sleep(for: .seconds(delay))
//                    return .mapAction(.sheetOpenStatusChanged(true))
//                }
                return .none
            case .homeAction(.departmentListAction(.listButtonTapped)):
                state.selection = 3
                return .none
            case .homeAction(.buildingListAction(.cellAction(id: let id, action: .buttonTapped))):
//                let selectedBuidling = state.homeState.buildingListState.buildings[id: id]
//                state.mapState = MapFeatureState(preselectionID: id)
//                state.selection = 2
                return .none
            case .homeAction(.clubHomeListAction(.listButtonTapped)):
                state.selection = 4
                return .none
            case .homeAction:
                return .none
//            case .mapAction:
//                return .none
            case .departmentsAction:
                return .none
            case .clubsAction:
                return .none
            case .infoAction:
                return .none
            case .newTabSelection(let selection):
                state.selection = selection
                return .none
            }
        }
    }
}

//MARK: - VIEW
public struct MenuView: View {
    let store: StoreOf<MenuFeature>
    
    public init(store: StoreOf<MenuFeature>) {
        self.store = store
    }
    
    public var body: some View {
		WithViewStore(store) { viewStore in
			TabView(
				selection: Binding(
					get: { viewStore.selection },
					set: { viewStore.send(.newTabSelection($0))}
				)
			) {
				HomeView(
					store: store.scope(
						state: \.homeState,
						action: MenuFeature.Action.homeAction
					)
				)
				.preferredColorScheme(.light)
				.tabItem {
					Image("SchoolIcon")
				}
				.tag(1)
				
//				MapFeatureView(
//					store: self.store.scope(
//						state: \.mapState,
//                        action: Menu.Action.mapAction
//					)
//				)
                AnyView(
                    Text("Ola will refactor this view")
                )
				.preferredColorScheme(.light)
				.tabItem {
					Image("CompassIcon")
				}
				.tag(2)
				
				DepartmentsView(
					store: store.scope(
						state: \.departmentsState,
						action: MenuFeature.Action.departmentsAction
					)
				)
				.preferredColorScheme(.light)
				.tabItem {
					Image("HatIcon")
				}
				.tag(3)
				
				ClubsView(
					store: store.scope(
						state: \.clubsState,
						action: MenuFeature.Action.clubsAction
					)
				)
				.preferredColorScheme(.light)
				.tabItem {
					Image("RocketIcon")
				}
				.tag(4)
                
				InfoView(
					store: store.scope(
						state: \.infoState,
						action: MenuFeature.Action.infoAction
					)
				)
				.preferredColorScheme(.light)
				.tabItem {
					Image("InfoIcon")
				}
				.tag(5)
			}.onAppear(perform: {
				UITabBar.appearance().backgroundColor = .systemBackground
			})
			.accentColor(K.Colors.firstColorDark)
            .navigationViewStyle(StackNavigationViewStyle())
		}
    }
}

#if DEBUG
// MARK: - Mock
extension MenuFeature.State {
    static let mock: Self = .init()
}

// MARK: - Preview
private struct MenuView_Preview: PreviewProvider {
    static var previews: some View {
        MenuView(
            store: .init(
                initialState: .mock,
                reducer: MenuFeature()
            )
        )
    }
}

#endif
