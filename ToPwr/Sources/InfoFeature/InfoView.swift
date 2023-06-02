import SwiftUI
import ComposableArchitecture
import Combine
import Common

//MARK: - STATE
public struct InfoState: Equatable {
    var listState = InfoListFeature.State()
	var showAlert = false
    
    public init(){}
}
//MARK: - ACTION
public enum InfoAction: Equatable {
    case onAppear
    case loadInfos
	case loadAboutUs
    case receivedInfos(Result<[Info], ErrorModel>)
	case receiveAboutUs(Result<AboutUs, ErrorModel>)
    case listAction(InfoListFeature.Action)
    case dismissKeyboard
	case showAlertStateChange(Bool)
}

//MARK: - ENVIRONMENT
public struct InfoEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getInfos: (Int) -> AnyPublisher<[Info], ErrorModel>
	let getAboutUs: () -> AnyPublisher<AboutUs, ErrorModel>
	
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getInfos: @escaping (Int) -> AnyPublisher<[Info], ErrorModel>,
		getAboutUs: @escaping () -> AnyPublisher<AboutUs, ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getInfos = getInfos
		self.getAboutUs = getAboutUs
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
//        if state.listState.infos.isEmpty {
//            return .concatenate (
//                .init(value: .loadInfos),
//                .init(value: .loadAboutUs)
//            )
//        } else {
//            return .none
//        }
        return .none
    case .loadInfos:
//        return env.getInfos(0)
//            .receive(on: env.mainQueue)
//            .catchToEffect()
//            .map(InfoAction.receivedInfos)
        return .none
    case .receivedInfos(.success(let Infos)):
//        var infos: IdentifiedArrayOf<InfoDetailsFeature.State> = .init(
//            uniqueElements: Infos.map {
//                InfoDetailsFeature.State(
//                    id: $0.id,
//                    url: $0.photo?.url,
//                    title: $0.title,
//                    description: $0.description,
//                    infoSection: $0.infoSection
//                )
//            }
//        )
//        state.listState.infos = infos
//        state.listState.filtered = infos
        return .none
    case .receivedInfos(.failure(let error)):
        //state.showAlert = true
        return .none
    case .dismissKeyboard:
        //UIApplication.shared.dismissKeyboard()
        return .none
    case .showAlertStateChange(let newState):
        //state.showAlert = newState
        return .none
    case .loadAboutUs:
//        return env.getAboutUs()
//            .receive(on: env.mainQueue)
//            .catchToEffect()
//            .map(InfoAction.receiveAboutUs)
        return .none
    case .receiveAboutUs(.success(let aboutUs)):
//        state.listState.aboutUs = InfoDetailsFeature.State(
//            id: aboutUs.id,
//            url: aboutUs.photo.url,
//            title: "About Us",
//            description: aboutUs.description,
//            infoSection: aboutUs.infoSection
//        )
        return .none
    case .receiveAboutUs(.failure(let error)):
        //print(error.localizedDescription)
        return .none
    }
}

//.combined(
//    with:
//        AnyReducer { environment in
//            InfoListFeature()
//        }
//        .pullback(
//            state: \.listState,
//            action: /InfoAction.listAction,
//            environment: { $0 }
//        )
//)

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
			.alert(
				isPresented: Binding(
					get: { viewStore.showAlert },
					set: { viewStore.send(.showAlertStateChange($0)) }
				)
			) {
				Alert(
					title: Text(Strings.Other.networkError),
					primaryButton: .default(
						Text(Strings.Other.tryAgain),
						action: {
							viewStore.send(.loadInfos)
					} ),
					secondaryButton: .cancel(Text(Strings.Other.cancel))
				)
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
#endif

