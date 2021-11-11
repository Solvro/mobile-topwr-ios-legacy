import SwiftUI
import ComposableArchitecture

//MARK: - STATE
public struct SearchState: Equatable {
    var search: String = ""
    let placeholder: String
    #warning("TODO: Strings")

    public init(
        placeholder: String = "Szukaj..."
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
        print(text)
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
                
                if viewStore.search.count > 0 {
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
            .cornerRadius(15)
            .background(K.SearchColors.lightGray)
            .padding(15)
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
