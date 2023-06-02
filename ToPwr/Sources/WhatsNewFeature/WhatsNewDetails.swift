import Foundation
import ComposableArchitecture
import SwiftUI
import Common

public struct WhatsNewDetailsFeature: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public let id: UUID
        let news: WhatsNew
        
        public init(
            id: UUID = UUID(),
            news: WhatsNew
        ) {
            self.id = id
            self.news = news
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case onDisappear
    }
    
    public var body: some ReducerProtocol<State, Action> {
        EmptyReducer()
    }
}

// MARK: - View
public struct WhatsNewDetailsView: View {
    
    private enum Constants {
        static let backgroundImageHeigth: CGFloat = 254
        static let dateWidth: CGFloat = 100
        static let dateHeight: CGFloat = 30
    }
    
    let store: StoreOf<WhatsNewDetailsFeature>
    
    public init(store: StoreOf<WhatsNewDetailsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView(showsIndicators: false) {
                VStack{
                    ImageView(
                        url:  viewStore.news.photo?.url,
                        contentMode: .aspectFill
                    )
                        .frame(height: Constants.backgroundImageHeigth)
                    HStack{
                        if let date = viewStore.news.dateLabel {
                            VStack {
                                Text(date)
                                    .foregroundColor(.white)
                                    .font(.appRegularTitle4)
                            }
                            .frame(
                                width: Constants.dateWidth,
                                height: Constants.dateHeight
                            )
                            .background(K.Colors.dateDark)
                            .cornerRadius(UIDimensions.huge.cornerRadius)
                            .horizontalPadding(.big)
                            .verticalPadding(.small)
                        }
                        Spacer()
                    }
                    HStack{
                        Text(viewStore.news.title)
                            .font(.appBoldTitle2)
                            .foregroundColor(.black)
                            .horizontalPadding(.big)
                            .padding(.bottom, UIDimensions.small.size)
                        Spacer()
                    }
                    
                    Text(viewStore.news.description ?? "")
                        .font(.appRegularTitle3)
                        .foregroundColor(.black)
                        .horizontalPadding(.big)
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .onDisappear {
                viewStore.send(.onDisappear)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#if DEBUG
// MARK: - Preview
extension WhatsNewDetailsFeature.State {
    static let mock: Self = .init(news: .mock)
}

struct WhatsNewDetails_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewDetailsView(store: .init(initialState: .mock, reducer: WhatsNewDetailsFeature()))
    }
}
#endif
