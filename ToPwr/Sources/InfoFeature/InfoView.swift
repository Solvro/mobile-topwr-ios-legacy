import SwiftUI
import ComposableArchitecture
import Combine
import Common

public struct InfoFeature: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        var listState = InfoListFeature.State()
        var showAlert = false
        
        public init(){}
    }
    
    public init() {}
    
    // MARK: - Action
    public enum Action: Equatable {
        case onAppear
        case loadInfos
        case loadAboutUs
        case receivedInfos(Result<[Info], ErrorModel>)
        case receiveAboutUs(Result<AboutUs, ErrorModel>)
        case listAction(InfoListFeature.Action)
        case dismissKeyboard
        case showAlertStateChange(Bool)
    }
    
    // MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        
        Scope(
            state: \.listState,
            action: /Action.listAction
        ) { () -> InfoListFeature in
            InfoListFeature()
        }
        
        Reduce { state, action in
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
    }
}

//MARK: - VIEW
public struct InfoView: View {
    let store: StoreOf<InfoFeature>
    
    public init(store: StoreOf<InfoFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                InfoListView(
                    store: self.store.scope(
                        state: \.listState,
                        action: InfoFeature.Action.listAction
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
// MARK: - Mock
extension InfoFeature.State {
    static let mock: Self = .init()
}

// MARK: - Preview
private struct InfoView_Preview: PreviewProvider {
    static var previews: some View {
        InfoView(
            store: .init(
                initialState: .mock,
                reducer: InfoFeature()
            )
        )
    }
}

#endif

