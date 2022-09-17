import Foundation
import ComposableArchitecture
import Combine
import SwiftUI
import Common

// MARK: - State
public struct WhatsNewListState: Equatable {
    let title: String = Strings.HomeLists.whatsnewListTitle
    
    var news: IdentifiedArrayOf<WhatsNewDetailsState> = .init(uniqueElements: [])
    var selection: Identified<WhatsNewDetailsState.ID, WhatsNewDetailsState?>?
    
    public init(
        news: [WhatsNew] = []
    ) {
        self.news = .init(
            uniqueElements: news.map {
                WhatsNewDetailsState(news: $0)
            }
        )
    }
}

// MARK: - Actions
public enum WhatsNewListAction: Equatable {
    case onAppear
    case buttonTapped
    case setNavigation(selection: UUID?)
    case whatsNewDetailsAction(WhatsNewDetailsAction)
}

// MARK: - Environment
public struct WhatsNewListEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

// MARK: - Reducer
public let whatsNewListReducer =
whatsNewDetailsReducer
.optional()
.pullback(state: \Identified.value, action: .self, environment: { $0 })
.optional()
.pullback(
  state: \WhatsNewListState.selection,
  action: /WhatsNewListAction.whatsNewDetailsAction,
  environment: { _ in
      WhatsNewDetailsEnvironment()
  }
)
.combined(
    with: Reducer<
    WhatsNewListState,
    WhatsNewListAction,
    WhatsNewListEnvironment
    > { state, action, env in
        switch action {
        case .onAppear:
            return .none
        case .buttonTapped:
            print("CELL TAPPED")
            return .none
        case let .setNavigation(selection: .some(id)):
            state.selection = Identified(nil, id: id)
            guard let id = state.selection?.id,
                  let new = state.news[id: id] else { return .none }
            state.selection?.value = new
            return .none
        case .setNavigation(selection: .none):
            state.selection = nil
            return .none
        case .whatsNewDetailsAction(_):
            return .none
        }
    }
)

// MARK: - View
public struct WhatsNewListView: View {
    
    private enum Constants {
    }
    
    let store: Store<WhatsNewListState, WhatsNewListAction>
    
    public init(store: Store<WhatsNewListState, WhatsNewListAction>) {
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
                        NavigationLink(
                            destination: IfLetStore(
                                self.store.scope(
                                    state: \.selection?.value,
                                    action: WhatsNewListAction.whatsNewDetailsAction
                                ),
                                then: WhatsNewDetailsView.init(store:),
                                else: ProgressView.init
                            ),
                            tag: new.id,
                            selection: viewStore.binding(
                                get: \.selection?.id,
                                send: WhatsNewListAction.setNavigation(selection:)
                            )
                        ) {
                            WhatsNewHomeCellView(viewState: new)
                        }
                    }
                }
                .horizontalPadding(.normal)
            }
        }
    }
}
