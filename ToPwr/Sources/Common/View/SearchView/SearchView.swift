import SwiftUI
import ComposableArchitecture

//MARK: - STATE
public struct SearchState: Equatable {
	let placeholder: String
	
	public init(
		placeholder: String = Strings.Other.searching
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
		return .none
	case .clearSearch:
		return .none
	}
}

//MARK: - VIEW
public struct SearchView: View {
	let store: Store<SearchState, SearchAction>
	// state property wrappers introduced in order to make textField work as intended within GeometryReader
	@State var textInField: String = ""
	
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
					.foregroundColor(K.SearchColors.darkGrey)
					.padding(8)
				
				TextField(
					viewStore.placeholder,
					text: Binding(
						get: {
							textInField
						},
						set: { newValue in
							// updating local source of truth
							textInField = newValue
							
							// sending global info about change
							viewStore.send(.update(newValue))
						}
					)
				)
				.foregroundColor(K.SearchColors.textColor)
				.padding(.trailing, 5)
				
				if !textInField.isEmpty {
					Button(
						action: {
							// global info about clear action
							viewStore.send(.clearSearch)
							// updating local source of truth
							textInField = ""
						},
						label: {
							Image(systemName: "x.circle.fill")
								.foregroundColor(K.SearchColors.darkGrey)
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
