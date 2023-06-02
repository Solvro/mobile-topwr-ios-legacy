import Foundation
import SwiftUI
import Common
import ComposableArchitecture

public struct InfoDetailsFeature: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public let id: Int
        let url: URL?
        let title: String
        let description: String?
        let infoSection: [InfoSection]
        
        public init(id: Int, url: URL?, title: String, description: String?, infoSection: [InfoSection]) {
            self.id = id
            self.url = url
            self.title = title
            self.description = description
            self.infoSection = infoSection
        }
    }
    
    public enum Action: Equatable {
        // TODO: - Does this do anything?
        case onAppear
    }
    
    public var body: some ReducerProtocol<State, Action> {
        EmptyReducer()
    }
}

//MARK: - VIEW
public struct InfoDetailsView: View {
	private enum Constants {
		static let backgroundImageHeigth: CGFloat = 254
		static let dateWidth: CGFloat = 100
		static let dateHeight: CGFloat = 30
	}
	
	let store: StoreOf<InfoDetailsFeature>
	
	public init(store: StoreOf<InfoDetailsFeature>) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(store, observe: { $0 }) { viewStore in
			ScrollView(showsIndicators: false) {
				VStack{
					ImageView(
						url:  viewStore.url,
						contentMode: .aspectFill
					)
					.frame(height: Constants.backgroundImageHeigth)
					HStack{
						Text(viewStore.title)
							.font(.appMediumTitle3)
							.foregroundColor(.black)
							.horizontalPadding(.big)
							.padding(.bottom, UIDimensions.small.size)
						Spacer()
					}
					
					Text(LocalizedStringKey(viewStore.description ?? ""))
						.font(.appRegularTitle3)
						.foregroundColor(.black)
						.horizontalPadding(.big)
					
					ForEach(viewStore.infoSection) { section in
						VStack(spacing: UIDimensions.normal.spacing) {
							InfoSectionView(section: section)
						}
					}
				}
			}
			.onAppear {
				viewStore.send(.onAppear)
			}
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}
