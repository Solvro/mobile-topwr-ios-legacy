import SwiftUI

public struct InfoCellView: View {
	private enum Constants {
		static let iconBackgroundSize: CGFloat = 35
		static let iconSize: CGFloat = 20
        static let minimumScaleFactor: CGFloat = 0.7
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
					contentMode: .fit
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
                    .minimumScaleFactor(Constants.minimumScaleFactor)
			}	else {
				Text(info.value ?? info.label ?? "")
					.underline()
					.foregroundColor(K.Colors.red)
					.verticalPadding(.normal)
                    .minimumScaleFactor(Constants.minimumScaleFactor)
			}
		}
		.horizontalPadding(.normal)
	}
}
