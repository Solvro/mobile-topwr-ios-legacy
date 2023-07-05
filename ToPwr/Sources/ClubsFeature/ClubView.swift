import SwiftUI
import ComposableArchitecture
import Combine
import Common

public struct ClubFeature: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        var listState: ClubList.State
        var showAlert = false
        public init(){
            self.listState = ClubList.State()
        }
    }
    
    public init() {}
    
    // MARK: - Action
    public enum Action: Equatable {
        case onAppear
        case loadClubs
        case receivedClubs(TaskResult<[ScienceClub]>)
        case listAction(ClubList.Action)
        case dismissKeyboard
        case showAlertStateChange(Bool)
    }
    
    // MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        
//        Scope(
//            state: \.listState,
//            action: /ClubFeature.Action.listAction
//        ) {
//            ClubList()
//        }
        
        Reduce { state, action in
            switch action {
            case .listAction:
                return .none
            case .onAppear:
                if state.listState.clubs.isEmpty {
                    return .init(value: .loadClubs)
                } else {
                    return .none
                }
            case .loadClubs:
                //                return env.getClubs(0)
                //                    .receive(on: env.mainQueue)
                //                    .catchToEffect()
                //                    .map(ClubsAction.receivedClubs)
                // TODO: - Load clubs
                return .none
            case .receivedClubs(.success(let clubs)):
                return .init(value: .listAction(.receivedClubs(.success(clubs))))
            case .receivedClubs(.failure(let error)):
                state.showAlert = true
                return .none
            case .dismissKeyboard:
                UIApplication.shared.dismissKeyboard()
                return .none
            case .showAlertStateChange(let newState):
                state.showAlert = newState
                return .none
            }
        }
    }
}

//MARK: - VIEW
public struct ClubsView: View {
    let store: StoreOf<ClubFeature>
    
    public init(store: StoreOf<ClubFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                ClubListView(
                    store: store.scope(
                        state: \.listState,
                        action: ClubFeature.Action.listAction
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
                // TODO: - Modify this to use AlerState
				Alert(
					title: Text(Strings.Other.networkError),
					primaryButton: .default(
						Text(Strings.Other.tryAgain),
						action: {
							viewStore.send(.loadClubs)
					} ),
					secondaryButton: .cancel(Text(Strings.Other.cancel))
				)
			}
        }
    }
}


#if DEBUG
// MARK: - Mock
extension ClubFeature.State {
    static let mock: Self = .init()
}

// MARK: - Preview
private struct ClubsView_Preview: PreviewProvider {
    static var previews: some View {
        ClubsView(
            store: .init(
                initialState: .mock,
                reducer: ClubFeature()
            )
        )
    }
}

#endif

