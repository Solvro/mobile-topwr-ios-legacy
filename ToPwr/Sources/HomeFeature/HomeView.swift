import SwiftUI
import ComposableArchitecture
import Common
import CellsFeature

//MARK: - STATE
public struct HomeState: Equatable {
    var text: String = "Hello World ToPwr"
    
    var departmentListState = DepartmentListState()
    
    var buildingCellState = BuildingCellState()
    var scienceClubCellState = ScienceClubCellState()
    public init(){}
}
//MARK: - ACTION
public enum HomeAction: Equatable {
    case buttonTapped
    case buildingCellAction(BuildingCellAction)
    case departmentListAction(DepartmentListAction)
    case scienceClubAction(ScienceClubCellAction)
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
    case .buildingCellAction:
        print("XDDD")
        return .none
    case .departmentListAction:
        return .none
    case .scienceClubAction:
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
                    // ONE
                    HStack() {
                        Text("Ostatnio wyszukiwane")
                            .bold()
                        Spacer()
                        Text("Mapa")
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(0..<5)  { _ in
                                BuildingCellView(imageURL: "XXX",
                                                 name: "B-4",
                                                 store: self.store.scope(
                                                    state: \.buildingCellState,
                                                    action: HomeAction.buildingCellAction))
                            }
                        }
                    }
                    .padding(.bottom, 30)
                    
                    // WYDZIAŁY
                    DepartmentListView(
                        store: self.store.scope(
                            state: \.departmentListState,
                            action: HomeAction.departmentListAction
                        )
                    )

                    
                    // THREE
                    HStack() {
                        Text("Koła naukowe")
                            .bold()
                        Spacer()
                    }
                    .padding(.trailing)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(0..<5)  { _ in
                                ScienceClubCellView(imageURL: "XXX", fullName: "KNN Solvro",
                                                    store: self.store.scope(
                                                        state: \.scienceClubCellState,
                                                        action: HomeAction.scienceClubAction))
                            }
                        }
                    }
                    .padding(.bottom, 30)
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
