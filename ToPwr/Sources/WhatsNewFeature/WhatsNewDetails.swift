import Foundation
import ComposableArchitecture
import SwiftUI
import Common

public struct WhatsNewDetailsFeature: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public let id: UUID
        let news: WhatsNew
        var newsComponents: [NewsComponent] = []
        
        public init(
            id: UUID = UUID(),
            news: WhatsNew
        ) {
            self.id = id
            self.news = news
        }
    }
    
    public init() {}
    
    public enum Action: Equatable {
        case onAppear
        case loadNewsComponents(TaskResult<[NewsComponent]>)
    }
    
    // MARK: - Dependency
    @Dependency(\.news) var newsClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if let url = state.news.detailsUrl {
                    return .task {
                        await .loadNewsComponents(TaskResult {
                            try await newsClient.getWhatsNewDetails(url)
                        })
                    }
                }
                return .none
            case .loadNewsComponents(.success(let components)):
                state.newsComponents = components
                return .none
            case .loadNewsComponents(.failure):
                return .none
            }
        }
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
    
    struct ViewState: Equatable {
        let isLoading: Bool
        let isScrapped: Bool
        let news: WhatsNew
        let scrappedNews: [NewsComponent]
        
        init(state: WhatsNewDetailsFeature.State) {
            self.isLoading = state.newsComponents.isEmpty
            self.isScrapped = state.news.detailsUrl != nil
            self.news = state.news
            self.scrappedNews = state.newsComponents
        }
    }
    
    public var body: some View {
        WithViewStore(store, observe: { ViewState(state: $0) }) { viewStore in
            Group {
                if viewStore.isScrapped {
                    if viewStore.isLoading {
                        VStack {
                            Spacer()
                            
                            ProgressView()
                                .onAppear {
                                    viewStore.send(.onAppear)
                                }
                            
                            Spacer()
                        }
                    } else {
                        ScrappedNewsView(news: viewStore.scrappedNews)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack {
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
                }
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
