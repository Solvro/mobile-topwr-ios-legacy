import SwiftUI
import ComposableArchitecture
import Combine
import Common

//MARK: - STATE
public struct InfoState: Equatable {
    var listState = InfoListState()
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
    case listAction(InfoListAction)
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
		if state.listState.infos.isEmpty {
			return .concatenate (
				.init(value: .loadInfos),
				.init(value: .loadAboutUs)
			)
		} else {
			return .none
		}
    case .loadInfos:
        return env.getInfos(0)
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map(InfoAction.receivedInfos)
    case .receivedInfos(.success(let Infos)):
		var infos: IdentifiedArrayOf<InfoDetailsState> = .init(
			uniqueElements: Infos.map {
				InfoDetailsState(info: $0)
			}
		)
		state.listState.infos = infos
		state.listState.filtered = infos
        return .none
	case .receivedInfos(.failure(let error)):
		state.showAlert = true
        return .none
    case .dismissKeyboard:
        UIApplication.shared.dismissKeyboard()
        return .none
	case .showAlertStateChange(let newState):
		state.showAlert = newState
		return .none
	case .loadAboutUs:
		return env.getAboutUs()
			.receive(on: env.mainQueue)
			.catchToEffect()
			.map(InfoAction.receiveAboutUs)
	case .receiveAboutUs(.success(let aboutUs)):
		state.listState.aboutUs = InfoDetailsState(
			info: Info(
				id: aboutUs.id,
				title: "O Nas!",
				description: aboutUs.content,
				infoSection: [],
				photo: aboutUs.photo,
				shortDescription: ""
			)
		)
		return .none
	case .receiveAboutUs(.failure(let error)):
		print(error.localizedDescription)
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
struct DepartmentsView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(
            store: Store(
                initialState: .init(),
                reducer: infoReducer,
                environment: .failing
            )
        )
    }
}

public extension InfoEnvironment {
    static let failing: Self = .init(
        mainQueue: .immediate,
		getInfos: failing1,
		getAboutUs: failing0
    )
}
#endif

