import SwiftUI
import ComposableArchitecture
import Common

public struct WhatsNewHomeCellView: View {
    let viewState: WhatsNewDetailsState

    private enum Constants {
        static let viewHeight: CGFloat = 365
        static let viewWidth: CGFloat = 275
        static let banerHeight: CGFloat = 135
        static let buttonHeight: CGFloat = 32
    }
    
    public init(
        viewState: WhatsNewDetailsState
    ) {
        self.viewState = viewState
    }
    
    public var body: some View {
        VStack {
            VStack {
                ImageView(
                    url: viewState.news.photo?.url,
                    contentMode: .aspectFill
                )
                    .cornerRadius(
                        UIDimensions.normal.cornerRadius - 3,
                        corners: [.topLeft, .topRight]
                    )
                    .frame(height: Constants.banerHeight)
            }
            .padding(3)
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    Text(viewState.news.title)
                        .font(.appBoldTitle2)
                    Spacer()
                }
                Text(viewState.news.description ?? "")
                    .font(.appRegularTitle2)
                    .verticalPadding(.normal)
                    .multilineTextAlignment(.leading)
                HStack {
                    Button(
                        action: {
                        #warning("TO DO")
                        },
                        label: {
                            HStack {
                                Text(Strings.Other.readMore)
                                    .font(.appBoldTitle2)
                                    .foregroundColor(K.Colors.white)
                            }
                            .horizontalPadding(.normal)
                            .frame(height: Constants.buttonHeight)
                            .background(K.Colors.red)
                            .cornerRadius(UIDimensions.normal.cornerRadius)
                        }
                    )
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
