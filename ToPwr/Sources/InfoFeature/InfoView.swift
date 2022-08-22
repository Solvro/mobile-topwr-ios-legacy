import SwiftUI
import ComposableArchitecture
import Combine
import Common

//MARK: - STATE
public struct InfoState: Equatable {
    var listState = InfoListState()
    
    public init(){}
}
//MARK: - ACTION
public enum InfoAction: Equatable {
    case onAppear
    case loadInfos
    case receivedInfos(Result<[Info], ErrorModel>)
    case listAction(InfoListAction)
    case dismissKeyboard
}

//MARK: - ENVIRONMENT
public struct InfoEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getInfos: (Int) -> AnyPublisher<[Info], ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getInfos: @escaping (Int) -> AnyPublisher<[Info], ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getInfos = getInfos
    }
}

//MARK: - REDUCER
public let infoReducer = Reducer<
    InfoState,
    InfoAction,
    InfoEnvironment
> { state, action, env in
    switch action {
    case .listAction:
        return .none
    case .onAppear:
        if state.listState.infos.isEmpty {
            return .init(value: .loadInfos)
        } else {
            return .none
        }
    case .loadInfos:
        return env.getInfos(0)
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map(InfoAction.receivedInfos)
    case .receivedInfos(.success(let Infos)):
        state.listState = .init(infos: Infos)
        return .none
    case .receivedInfos:
        return .none
    case .dismissKeyboard:
        UIApplication.shared.dismissKeyboard()
        return .none
    }
}
.combined(
    with: InfoListReducer
        .pullback(
            state: \.listState,
            action: /InfoAction.listAction,
            environment: {
                .init(
                    mainQueue: $0.mainQueue,
                    getInfos: $0.getInfos
                )
            }
        )
)
//MARK: - VIEW
public struct InfoView: View {
    let store: Store<InfoState, InfoAction>
    
    public init(
        store: Store<InfoState, InfoAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                InfoListView(
                    store: self.store.scope(
                        state: \.listState,
                        action: InfoAction.listAction
                    )
                )
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

#if DEBUG
//struct DepartmentsView_Previews: PreviewProvider {
//    static var previews: some View {
//        InfoView(
//            store: Store(
//                initialState: .init(),
//                reducer: infoReducer,
//                environment: .failing
//            )
//        )
//    }
//}

public extension InfoEnvironment {
    static let failing: Self = .init(
        mainQueue: .immediate,
        getInfos: failing1
    )
}
#endif

