import SwiftUI
import ComposableArchitecture
import Common
import Cells

//MARK: - STATE
public struct HomeState: Equatable {
    var text: String = "Hello World ToPwr"
    
    var buildingCellState = BuildingCellState()
    var departmentCellState = DepartmentCellState()
    var scienceClubCellState = ScienceClubCellState()
    public init(){}
}
//MARK: - ACTION
public enum HomeAction: Equatable {
    case buttonTapped
    case buildingCellAction(BuildingCellAction)
    case departmentCellAction(DepartmentCellAction)
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
    case .departmentCellAction:
        return .none
    case .scienceClubAction:
        return .none
    }
}

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
                    
                    // TWO
                    HStack() {
                        Text("Wydziały")
                            .bold()
                        Spacer()
                        Text("Lista")
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(0..<5)  { _ in
                                DepartmentCellView(imageURL: "XXX", name: "W-1", fullName: "Wydział Architektury", store: self.store.scope(
                                        state: \.departmentCellState,
                                        action: HomeAction.departmentCellAction))
                            }
                        }
                    }
                    .padding(.bottom, 30)
                    
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
