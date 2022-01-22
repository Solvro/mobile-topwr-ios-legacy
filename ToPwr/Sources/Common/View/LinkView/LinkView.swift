import SwiftUI
import NukeUI

public struct LinkView: View {
    private enum Constants {
        static let iconBackgroundSize: CGFloat = 35
        static let iconSize: CGFloat = 20
    }
    let link: LinkComponent
    
    public init(
        link: LinkComponent
    ) {
        self.link = link
    }
    
    public var body: some View {
        HStack {
                ZStack {
                    K.Colors.white
                        .cornerRadius(UIDimensions.small.cornerRadius)
                        .shadow(.down, radius: 1)
                        .frame(
                            width: Constants.iconBackgroundSize,
                            height: Constants.iconBackgroundSize
                        )
                    
                    ImageView(
                        url: link.icon?.url,
                        contentMode: .aspectFit
                    )
                        .foregroundColor(.red)
                        .frame(
                            width: Constants.iconSize,
                            height: Constants.iconSize
                        )
                }
                #warning("TODO: Contact link")
                Text(link.name ?? "")
                    .foregroundColor(K.Colors.red)
                    .underline()
                    .verticalPadding(.normal)
        }
        .horizontalPadding(.normal)
    }
}
