import Foundation
import ComposableArchitecture
import SwiftUI
import Common

// MARK: - State
public struct WhatsNewDetailsState: Equatable, Identifiable {
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

// MARK: - Actions
public enum WhatsNewDetailsAction: Equatable {
    case onAppear
    case onDisappear
}

// MARK: - Environment
public struct WhatsNewDetailsEnvironment {
    public init () { }
}

// MARK: - Reducer
public let whatsNewDetailsReducer = Reducer<
    WhatsNewDetailsState,
    WhatsNewDetailsAction,
    WhatsNewDetailsEnvironment
> { _, action, _ in
    switch action {
    case .onAppear:
        return .none
    case .onDisappear:
        return .none
    }
}

// MARK: - View
public struct WhatsNewDetailsView: View {
    
    private enum Constants {
        static let backgroundImageHeigth: CGFloat = 254
        static let imageWidth: CGFloat = 100
        static let imageHeight: CGFloat = 30
    }
    
    let store: Store<WhatsNewDetailsState, WhatsNewDetailsAction>
    
    public init(store: Store<WhatsNewDetailsState, WhatsNewDetailsAction>) {
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
                        RoundedRectangle(cornerRadius: 20)
                            .frame(
                                width: Constants.imageWidth,
                                height: Constants.imageHeight
                            )
                            .foregroundColor(.gray)
                            .horizontalPadding(.big)
                            .verticalPadding(.small)
                            .overlay(
                                Text("TO DO")
                                        .foregroundColor(.white)
                                        .font(.appRegularTitle4)
                            )
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
struct WhatsNewDetails_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewDetailsView(
            store: Store(
                initialState: WhatsNewDetailsState.mock,
                reducer: whatsNewDetailsReducer,
                environment: WhatsNewDetailsEnvironment.mock
            )
        )
    }
}
// MARK: - State - MOCKS
public extension WhatsNewDetailsState {
    static let mock: Self = .init(
        news: .mock
    )
}

// MARK: - Environment - MOCKS
public extension WhatsNewDetailsEnvironment {
    static let mock: Self = .init()
}
#endif
