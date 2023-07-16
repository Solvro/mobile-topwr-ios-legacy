import SwiftUI
import ComposableArchitecture
import DepartmentsFeature
import WhatsNewFeature
import ClubsFeature
import Common

//MARK: - VIEW
public struct HomeView: View {
    let store: StoreOf<Home>
    
    public init(store: StoreOf<Home>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStackStore(store.scope(
            state: \.destinations,
            action: Home.Action.destinations
        )) {
        WithViewStore(store) { viewStore in
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
        } destination: {
            switch $0 {
            case .whatsNewDetails:
                CaseLet(
                    /Home.Destinations.State.whatsNewDetails,
                    action: Home.Destinations.Action.whatsNewDetails,
                    then: WhatsNewDetailsView.init(store:)
                )
            case .club:
                CaseLet(
                    /Home.Destinations.State.club,
                     action: Home.Destinations.Action.club,
                     then: ClubDetailsView.init(store:)
                )
            }
        }
    }
}

#if DEBUG

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
