import SwiftUI
import ComposableArchitecture
import Common

public struct WhatsNewHomeCellView: View {
    let viewState: WhatsNewDetailsState

    private enum Constants {
        static let viewHeight: CGFloat = 380
        static let viewWidth: CGFloat = 275
        static let banerHeight: CGFloat = 135
        static let buttonHeight: CGFloat = 32
		static let dateHeight: CGFloat = 20
		static let dateWidth: CGFloat = 100
    }
    
    public init(
        viewState: WhatsNewDetailsState
    ) {
        self.viewState = viewState
    }
    
    public var body: some View {
        VStack {
            ZStack {
                ImageView(
                    url: viewState.news.photo?.url,
                    contentMode: .aspectFill
                )
                    .cornerRadius(
                        UIDimensions.normal.cornerRadius - 3,
                        corners: [.topLeft, .topRight]
                    )
                    .frame(height: Constants.banerHeight)
					.overlay {
						if let safeDate = viewState.news.dateLabel {
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
                    Text(viewState.news.title)
                        .font(.appMediumTitle3)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                Text(viewState.news.description ?? "")
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
