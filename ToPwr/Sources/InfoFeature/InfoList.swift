import SwiftUI
import ComposableArchitecture
import Combine
import Common

public struct InfoListFeature: ReducerProtocol {
    public struct State: Equatable {
        var infos: IdentifiedArrayOf<InfoDetailsFeature.State>
        var filtered: IdentifiedArrayOf<InfoDetailsFeature.State>
        public var aboutUs: InfoDetailsFeature.State?
        // FIXME: - What placeholder?
        var searchState: SearchFeature.State = SearchFeature.State(placeholder: "")
        var text: String = ""
        var isFetching = false
        var noMoreFetches = false
        
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
        case receivedInfos(TaskResult<[Info]>)
        case fetchingOn
        case loadMoreInfos
        case navigateToDetails(InfoDetailsFeature.State)
        case navigateToAboutUs
    }
    
    public var body: some ReducerProtocol<State, Action> {
        
        Scope(
            state: \.searchState,
            action: /Action.searchAction
        ) { () -> SearchFeature in
            SearchFeature()
        }
        
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
            case .navigateToAboutUs:
                return .none
            case .navigateToDetails:
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
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    SearchView(
                        store: self.store.scope(
                            state: \.searchState,
                            action: InfoListFeature.Action.searchAction
                        )
                    ).padding(.bottom, 16)
                    LazyVStack(spacing: 16) {
                        
                        if viewStore.aboutUs != nil {
                            Button {
                                viewStore.send(.navigateToAboutUs)
                            } label: {
                                InfoCellView(
                                    title: "O Nas!",
                                    url: viewStore.aboutUs?.url,
                                    isAboutUs: true
                                )
                            }
                        }
                        
                        ForEach(viewStore.filtered) { info in
                            Button {
                                viewStore.send(.navigateToDetails(info))
                            } label: {
                                InfoCellView(
                                    title: info.title,
                                    url: info.url,
                                    description: info.shortDescription
                                )
                            }
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
