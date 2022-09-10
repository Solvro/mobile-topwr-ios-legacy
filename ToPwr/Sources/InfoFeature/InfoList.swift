import SwiftUI
import ComposableArchitecture
import Combine
import Common

//MARK: - STATE
public struct InfoListState: Equatable {
	var infos: IdentifiedArrayOf<InfoDetailsState> = .init(uniqueElements: [])
	var filtered: IdentifiedArrayOf<InfoDetailsState> = .init(uniqueElements: [])
	var selection: Identified<InfoDetailsState.ID, InfoDetailsState?>?
	var aboutUs: InfoDetailsState?
	
	var searchState = SearchState()
	var text: String = ""
	
	var isLoading: Bool {
		infos.isEmpty ? true : false
	}
	
	public init(
		infos: [Info] = [],
		aboutUs: AboutUs? = nil
	) {
		self.infos = .init(
			uniqueElements: infos.map {
				InfoDetailsState(info: $0)
			}
		)
		if let safeAboutUs = aboutUs {
			self.aboutUs = InfoDetailsState(
				info: Info(
					id: safeAboutUs.id,
					title: "O Nas!",
					description: safeAboutUs.content,
					infoSection: [],
					photo: safeAboutUs.photo,
					shortDescription: ""
				)
			)
		}
		self.filtered = self.infos
	}
}

//MARK: - ACTION
public enum InfoListAction: Equatable {
	case onAppear
	case searchAction(SearchAction)
	case setNavigation(selection: UUID?)
	case infoDetailsAction(InfoDetailsAction)
}

//MARK: - ENVIRONMENT
public struct InfoListEnvironment {
	let mainQueue: AnySchedulerOf<DispatchQueue>
	
	public init (
		mainQueue: AnySchedulerOf<DispatchQueue>
	) {
		self.mainQueue = mainQueue
	}
}
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
			}
		}
	)
//MARK: - VIEW
public struct InfoListView: View {
	let store: Store<InfoListState, InfoListAction>
	
	public init(
		store: Store<InfoListState, InfoListAction>
	) {
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
								action: InfoListAction.searchAction
							)
						).padding(.bottom, 16)
						LazyVStack(spacing: 16) {
							NavigationLink {
								IfLetStore(
									self.store.scope(
										state: \.aboutUs,
										action: InfoListAction.infoDetailsAction
									),
									then: InfoDetailsView.init(store:),
									else: ProgressView.init
								)
							} label: {
								if viewStore.aboutUs != nil {
									InfoCellView(
										title: "O Nas!",
										url: viewStore.aboutUs?.info.photo?.url,
										isAboutUs: true
									)
								}
							}
							
							ForEach(viewStore.filtered) { club in
								NavigationLink(
									destination: IfLetStore(
										self.store.scope(
											state: \.selection?.value,
											action: InfoListAction.infoDetailsAction
										),
										then: InfoDetailsView.init(store:),
										else: ProgressView.init
									),
									tag: club.id,
									selection: viewStore.binding(
										get: \.selection?.id,
										send: InfoListAction.setNavigation(selection:)
									)
								) {
									InfoCellView(
										title: club.info.title,
										url: club.info.photo?.url,
										description: club.info.shortDescription
									)
								}
							}
						}
					}
				}
				.barLogo()
				.navigationTitle(Strings.HomeLists.infosListTitle)
			}
		}
	}
}
