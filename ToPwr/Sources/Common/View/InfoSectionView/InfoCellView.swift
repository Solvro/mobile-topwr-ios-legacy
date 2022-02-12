import SwiftUI
import NukeUI

public struct InfoCellView: View {
    private enum Constants {
        static let iconBackgroundSize: CGFloat = 35
        static let iconSize: CGFloat = 20
    }
    let info: InfoComponent
    
    public init(
        info: InfoComponent
    ) {
        self.info = info
    }
    
    public var body: some View {
        HStack {
                ZStack {
                    K.Colors.white
                        .cornerRadius(UIDimensions.small.cornerRadius)
                        .shadow(radius: 1, y: 1)
                        .frame(
                            width: Constants.iconBackgroundSize,
                            height: Constants.iconBackgroundSize
                        )
                    
                    ImageView(
                        url: info.icon?.url,
                        contentMode: .aspectFit
                    )
                        .foregroundColor(.red)
                        .frame(
                            width: Constants.iconSize,
                            height: Constants.iconSize
                        )
                }
            Text(info.label ?? info.value ?? "")
                .underline()
                .foregroundColor(K.Colors.red)
                .verticalPadding(.normal)
        }
        .horizontalPadding(.normal)
    }
}
