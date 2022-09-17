import SwiftUI
import ComposableArchitecture
import Common

public struct ClubHomeCellView: View {
    let viewState: ClubDetailsState

    private enum Constants {
        static let viewHeight: CGFloat = 365
        static let viewWidth: CGFloat = 275
        static let banerHeight: CGFloat = 135
        static let buttonHeight: CGFloat = 32
    }
    
    public init(
        viewState: ClubDetailsState
    ) {
        self.viewState = viewState
    }
    
    public var body: some View {
        VStack {
            VStack {
                ImageView(
                    url: viewState.club.photo?.url,
                    contentMode: .aspectFill
                )
                    .cornerRadius(
                        UIDimensions.normal.cornerRadius - 3,
                        corners: [.topLeft, .topRight]
                    )
                    .frame(height: Constants.banerHeight)
            }
            .padding(1)
            VStack(alignment: .leading) {
                HStack {
                    Text(viewState.club.name ?? "")
                        .font(.appMediumTitle3)
                    Spacer()
                }
                Text(viewState.club.description ?? "")
                    .font(.appRegularTitle4)
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
                                    .font(.appMediumTitle4)
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
