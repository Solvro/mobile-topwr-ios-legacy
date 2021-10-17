import SwiftUI
import ComposableArchitecture
import Common

//MARK: - STATE
public struct HomeState: Equatable {
    var text: String = "Hello World ToPwr"
    public init(){}
}
//MARK: - ACTION
public enum HomeAction: Equatable {
    case buttonTapped
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
                VStack {
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
                    .padding(.leading, 20)
                    .padding([.top, .bottom], 35)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Cześć, miło Cię widzieć")
                            Text("w Parzysty Piątek!")
                                .fontWeight(.bold)
                        }
                        .padding(20)
                        Spacer()
                    }
                    
                    DaysToSessionView(sessionDate: Date(year: 2022, month: 02, day: 28))
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
                environment: .init(mainQueue: .immediate)
            )
        )
    }
}
#endif
