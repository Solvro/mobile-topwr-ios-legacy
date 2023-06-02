import SwiftUI
import ComposableArchitecture
import Combine
import Common

public struct InfoListFeature: ReducerProtocol {
    public struct State: Equatable {
        var infos: IdentifiedArrayOf<InfoDetailsFeature.State>
        var filtered: IdentifiedArrayOf<InfoDetailsFeature.State>
        var aboutUs: InfoDetailsFeature.State?
        // FIXME: - What placeholder?
        var searchState: SearchFeature.State = SearchFeature.State(placeholder: "")
        var text: String = ""
        var isFetching = false
        var noMoreFetches = false
        
        var isLoading: Bool {
            infos.isEmpty ? true : false
        }
        
        public init(
            infos: IdentifiedArrayOf<InfoDetailsFeature.State> = .init(uniqueElements: []),
            aboutUs: InfoDetailsFeature.State? = nil,
            text: String = "",
            isFetching: Bool = true,
            noMoreFetches: Bool = false
        ) {
            self.infos = infos
            self.filtered = infos
            self.aboutUs = aboutUs
            self.text = text
            self.isFetching = isFetching
            self.noMoreFetches = noMoreFetches
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case searchAction(SearchFeature.Action)
        //case setNavigation(selection: UUID?)
        //case infoDetailsAction(InfoDetailsFeature.Action)
        case receivedInfos(TaskResult<[Info]>)
        case fetchingOn
        case loadMoreInfos
    }
    
    // TODO: - add as dependancy
    // let getInfos: (Int) -> AnyPublisher<[Info], ErrorModel>
    
    public var body: some ReducerProtocol<State, Action> {
        
//        Scope(state: \.searchState, action: /Action.searchAction) {
//            SearchFeature()
//        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .searchAction(_):
                return .none
            case .receivedInfos(_):
                return .none
            case .fetchingOn:
                return .none
            case .loadMoreInfos:
                return .none
            }
        }
    }
}

//MARK: - VIEW
public struct InfoListView: View {
	
	private enum Constants {
		static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
	}
	
	let store: StoreOf<InfoListFeature>
	
	public init(store: StoreOf<InfoListFeature>) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(store) { viewStore in
			NavigationView {
				VStack {
					ScrollView(.vertical, showsIndicators: false) {
						SearchView(
							store: self.store.scope(
								state: \.searchState,
                                action: InfoListFeature.Action.searchAction
							)
						).padding(.bottom, 16)
						LazyVStack(spacing: 16) {
                            Text("About us was here. Also needs refactoring")
//							NavigationLink {
//								IfLetStore(
//									self.store.scope(
//										state: \.aboutUs,
//										action: InfoListAction.infoDetailsAction
//									),
//									then: InfoDetailsView.init(store:),
//									else: ProgressView.init
//								)
//							} label: {
//								if viewStore.aboutUs != nil {
//									InfoCellView(
//										title: "O Nas!",
//										url: viewStore.aboutUs?.info.photo?.url,
//										isAboutUs: true
//									)
//								}
//							}
							
							ForEach(viewStore.filtered) { club in
//								NavigationLink(
//									destination: IfLetStore(
//										self.store.scope(
//											state: \.selection?.value,
//											action: InfoListAction.infoDetailsAction
//										),
//										then: InfoDetailsView.init(store:),
//										else: ProgressView.init
//									),
//									tag: club.id,
//									selection: viewStore.binding(
//										get: \.selection?.id,
//										send: InfoListAction.setNavigation(selection:)
//									)
//								) {
//									InfoCellView(
//										title: club.info.title,
//										url: club.info.photo?.url,
//										description: club.info.shortDescription
//									)
//								}
                                Text("There was a navigation link here. Navigation needs refactoring")
							}
							if let safeVerion = Constants.appVersion {
								Text("Version \(safeVerion)")
									.font(.appRegularTitle6)
									.foregroundColor(.gray)
									.padding(.bottom, 16)
							}
						}
                        .padding(.bottom, UIDimensions.normal.size)
					}
				}
				.barLogo()
				.navigationTitle(Strings.HomeLists.infosListTitle)
			}
		}
	}
}

/*
 //MARK: - REDUCER
 public let InfoListReducer =
 infoDetailsReducer
     .optional()
     .pullback(state: \Identified.value, action: .self, environment: { $0 })
     .optional()
     .pullback(
         state: \InfoListState.selection,
         action: /InfoListAction.infoDetailsAction,
         environment: {
             InfoDetailsEnvironment(
                 mainQueue: $0.mainQueue
             )
         }
     )
     .combined(
         with: Reducer<
         InfoListState,
         InfoListAction,
         InfoListEnvironment
         > { state, action, env in
             switch action {
             case .onAppear:
                 return .none
             case .searchAction(.update(let text)):
                 state.text = text
                 
                 if text.count == 0 {
                     state.filtered = state.infos
                 } else {
                     state.filtered = .init(
                         uniqueElements: state.infos.filter {
                             $0.info.title.contains(text) ||
                             $0.info.description?.contains(text) ?? false
                         }
                     )
                 }
                 return .none
             case .searchAction:
                 return .none
             case let .setNavigation(selection: .some(id)):
                 state.selection = Identified(nil, id: id)
                 guard let id = state.selection?.id,
                       let info = state.filtered[id: id] else { return .none }
                 state.selection?.value = info
                 return .none
             case .setNavigation(selection: .none):
                 state.selection = nil
                 return .none
             case .infoDetailsAction:
                 return .none
             case .fetchingOn:
                 state.isFetching = true
                 return .none
             case .receivedInfos(.success(let infos)):
                 if infos.isEmpty {
                     state.noMoreFetches = true
                     state.isFetching = false
                     return .none
                 }
                 infos.forEach { state.infos.append(InfoDetailsState(info: $0)) }
                 state.filtered = state.infos
                 state.isFetching = false
                 return .none
             case .receivedInfos(.failure(_)):
                 return .none
             case .loadMoreInfos:
                 return env.getInfos(state.infos.count)
                     .receive(on: env.mainQueue)
                     .catchToEffect()
                     .map(InfoListAction.receivedInfos)
             }
         }
     )
 */
