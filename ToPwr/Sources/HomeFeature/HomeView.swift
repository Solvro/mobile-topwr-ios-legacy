import SwiftUI
import ComposableArchitecture
import Common
import CellsFeature

//MARK: - STATE
public struct HomeState: Equatable {
    var text: String = "Hello World ToPwr"
    
    var departmentListState = DepartmentListState()
    var buildingListState = BuildingListState()
    var scienceClubListState = ScienceClubListState()

    public init(){}
}
//MARK: - ACTION
public enum HomeAction: Equatable {
    case buttonTapped
    case departmentListAction(DepartmentListAction)
    case buildingListAction(BuildingListAction)
    case scienceClubListAction(ScienceClubListAction)
}

//MARK: - ENVIRONMENT
public struct HomeEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let homeReducer = Reducer<
    HomeState,
    HomeAction,
    HomeEnvironment
> { state, action, environment in
    switch action {
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
                        VStack(alignment: .leading) {
                            Text("Cześć, miło Cię widzieć")
                            Text("w Parzysty Piątek!")
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                    DaysToSessionView(sessionDate: Date(year: 2022, month: 02, day: 28))
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
            .padding(.leading)
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
                environment: .init(mainQueue: .immediate)
            )
        )
    }
}
#endif
