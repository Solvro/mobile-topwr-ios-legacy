import SwiftUI
import ComposableArchitecture
import Strings

//MARK: - STATE
public struct SearchState: Equatable {
    var search: String = ""
    let placeholder: String

    public init(
        placeholder: String = Strings.Search.searching
    ){
        self.placeholder = placeholder
    }
}
//MARK: - ACTION
public enum SearchAction: Equatable {
    case update(String)
    case clearSearch
}

//MARK: - ENVIRONMENT
public struct SearchEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let searchReducer = Reducer<
    SearchState,
    SearchAction,
    SearchEnvironment
> { state, action, env in
    switch action {
    case .update(let text):
        state.search = text
        return .none
    case .clearSearch:
        state.search = ""
        return .none
    }
}

//MARK: - VIEW
public struct SearchView: View {
    let store: Store<SearchState, SearchAction>
    
    public init(
        store: Store<SearchState, SearchAction>
    ) {
        self.store = store
    }
#warning("Implement rounded search field in the better way")
    public var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(K.SearchColors.darkGray)
                    .padding(8)
                
                TextField(
                    viewStore.placeholder,
                    text: viewStore.binding(
                        get: \.search,
                        send: SearchAction.update
                    )
                )
                .foregroundColor(K.SearchColors.textColor)
                .padding(.trailing, 5)
                
                if !viewStore.search.isEmpty {
                    Button(
                        action: {
                            viewStore.send(.clearSearch)
                        },
                        label: {
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(K.SearchColors.darkGray)
                                .padding(8)
                        }
                    )

                }
            }
            .background(K.SearchColors.lightGray)
            .cornerRadius(8)
            .padding(.horizontal, 15)
        }
    }
}

//MARK: - MOCKS & PREVIEW
#if DEBUG
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(
            store: Store(
                initialState: .init(),
                reducer: searchReducer,
                environment: .failing
            )
        )
    }
}

public extension SearchEnvironment {
    static let failing: Self = .init(
        mainQueue: .immediate
    )
}
#endif
