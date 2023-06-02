import SwiftUI
import ComposableArchitecture
import Common

public struct WhatsNewHomeCellFeature: Reducer {
    public struct State: Equatable, Identifiable {
        let url: URL?
        let dateLabel: String?
        let title: String
        let description: String?
        public let id: Int
        
        public init(url: URL?, dateLabel: String?, title: String, description: String?, id: Int) {
            self.url = url
            self.dateLabel = dateLabel
            self.title = title
            self.description = description
            self.id = id
        }
    }
    
    public enum Action: Equatable {
        case cellTapped
    }
    
    public var body: some ReducerOf<WhatsNewHomeCellFeature> {
        EmptyReducer()
    }
}

public struct WhatsNewHomeCellView: View {
    
    let store: StoreOf<WhatsNewHomeCellFeature>

    public init(store: StoreOf<WhatsNewHomeCellFeature>) {
        self.store = store
    }
    
    private enum Constants {
        static let viewHeight: CGFloat = 380
        static let viewWidth: CGFloat = 275
        static let banerHeight: CGFloat = 135
        static let buttonHeight: CGFloat = 32
		static let dateHeight: CGFloat = 20
		static let dateWidth: CGFloat = 100
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                viewStore.send(.cellTapped)
            } label: {
                VStack {
                    ZStack {
                        ImageView(
                            url: viewStore.url,
                            contentMode: .aspectFill
                        )
                        .cornerRadius(
                            UIDimensions.normal.cornerRadius - 3,
                            corners: [.topLeft, .topRight]
                        )
                        .frame(height: Constants.banerHeight)
                        .overlay {
                            if let safeDate = viewStore.dateLabel {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Capsule()
                                            .frame(
                                                width: Constants.dateWidth,
                                                height: Constants.dateHeight
                                            )
                                            .padding(.small)
                                            .foregroundColor(K.Colors.dateDark)
                                            .overlay {
                                                Text(safeDate)
                                                    .foregroundColor(.white)
                                                    .font(.appMediumTitle3)
                                            }
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(3)
                    Spacer()
                    VStack(alignment: .leading) {
                        HStack {
                            Text(viewStore.title)
                                .font(.appMediumTitle3)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        Text(viewStore.description ?? "")
                            .font(.appRegularTitle4)
                            .verticalPadding(.normal)
                            .multilineTextAlignment(.leading)
                        HStack {
                            HStack {
                                Text(Strings.Other.readMore)
                                    .font(.appMediumTitle4)
                                    .foregroundColor(K.Colors.white)
                            }
                            .horizontalPadding(.normal)
                            .frame(height: Constants.buttonHeight)
                            .background(K.Colors.red)
                            .cornerRadius(UIDimensions.normal.cornerRadius)
                            Spacer()
                        }
                    }
                    .padding(.normal)
                }
                .frame(
                    width: Constants.viewWidth,
                    height: Constants.viewHeight
                )
                .foregroundColor(Color.black)
                .background(K.Colors.lightGray)
                .cornerRadius(UIDimensions.normal.cornerRadius)
            }
        }
    }
}
