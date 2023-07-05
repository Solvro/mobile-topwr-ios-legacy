import Foundation
import ComposableArchitecture
import Combine
import SwiftUI
import Common

public struct WhatsNewListFeature: ReducerProtocol {
    public struct State: Equatable {
        let title: String = Strings.HomeLists.whatsnewListTitle
        let news: IdentifiedArrayOf<WhatsNew>
        var cells: IdentifiedArrayOf<WhatsNewHomeCellFeature.State>
        
        public init(
            news: [WhatsNew] = []
        ) {
            self.news = .init(uniqueElements: news)
            self.cells = .init(uniqueElements: news.map { .init(
                url: $0.photo?.url,
                dateLabel: $0.dateLabel,
                title: $0.title,
                description: $0.description,
                id: $0.id
            ) })
        }
    }
    
    public init() {}
    
    public enum Action: Equatable {
        case cellTapped(id: WhatsNewHomeCellFeature.State.ID, action: WhatsNewHomeCellFeature.Action)
        case navigateToDetails(WhatsNewDetailsFeature.State)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .cellTapped(id: id, action: .cellTapped):
                guard let news = state.news[id: id] else {
                    return .none
                }
                return .task {
                    .navigateToDetails(.init(news: news))
                }
            case .navigateToDetails:
                return .none
            }
        }
        .forEach(
            \.cells,
             action: /Action.cellTapped
        ) {
            WhatsNewHomeCellFeature()
        }
    }
}



// MARK: - View
public struct WhatsNewListView: View {
    
    private enum Constants {
    }
    
    let store: StoreOf<WhatsNewListFeature>
    
    public init(store: StoreOf<WhatsNewListFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            HStack() {
                Text(viewStore.title)
                    .font(.appMediumTitle2)
                    .foregroundColor(K.FontColors.primary)
                Spacer()
            }
            .horizontalPadding(.normal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(viewStore.news) { new in
                        // FIXME: - Implement simple cell views here. Navigation will be handled from home via navigation stack
//                        NavigationLink(
//                            destination: IfLetStore(
//                                self.store.scope(
//                                    state: \.selection?.value,
//                                    action: WhatsNewListAction.whatsNewDetailsAction
//                                ),
//                                then: WhatsNewDetailsView.init(store:),
//                                else: ProgressView.init
//                            ),
//                            tag: new.id,
//                            selection: viewStore.binding(
//                                get: \.selection?.id,
//                                send: WhatsNewListAction.setNavigation(selection:)
//                            )
//                        ) {
//                            WhatsNewHomeCellView(viewState: new)
//                        }
                        Text("What's new home cell here")
                    }
                }
                .horizontalPadding(.normal)
            }
        }
    }
}
