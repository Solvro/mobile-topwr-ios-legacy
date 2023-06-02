import SwiftUI
import ComposableArchitecture

public struct SearchFeature: Reducer {
    public struct State: Equatable {
        let placeholder: String
        
        public init(placeholder: String) {
            self.placeholder = placeholder
        }
    }
    
    public enum Action: Equatable {
        case update(String)
        case clearSearch
    }
    
    public var body: some ReducerOf<SearchFeature> {
        EmptyReducer()
    }
}

//MARK: - VIEW
public struct SearchView: View {
	let store: StoreOf<SearchFeature>
	// state property wrappers introduced in order to make textField work as intended within GeometryReader
	@State var textInField: String = ""
	
	public init(store: StoreOf<SearchFeature>) {
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

extension SearchFeature.State {
    static let mock: Self = .init(placeholder: "Mock placeholder")
}

struct SearchView_Previews: PreviewProvider {
	static var previews: some View {
		SearchView(
            store: .init(initialState: .mock, reducer: SearchFeature())
		)
	}
}
#endif
