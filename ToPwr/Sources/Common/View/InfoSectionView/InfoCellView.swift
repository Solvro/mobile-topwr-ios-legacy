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
			if info.type == .addres {
				Text(info.value ?? info.label ?? "")
					.verticalPadding(.normal)
			}	else {
				Text(info.value ?? info.label ?? "")
					.underline()
					.foregroundColor(K.Colors.red)
					.verticalPadding(.normal)
			}
        }
        .horizontalPadding(.normal)
    }
}
