import SwiftUI
import ComposableArchitecture
import Common

public struct InfoCellView: View {
	let title: String
	let photoUrl: URL?
	let description: String?
	let isAboutUs: Bool
    
    public init(
		title: String,
		url: URL?,
		isAboutUs: Bool = false,
		description: String? = nil
    ) {
		self.title = title
		self.photoUrl = url
		self.isAboutUs = isAboutUs
		self.description = description
	}
	
	public var body: some View {
		ZStack(alignment: .topLeading) {
			K.CellColors.scienceBackground
			HStack {
				VStack(alignment: .leading) {
					Text(title)
						.font(isAboutUs ? .appBoldTitle2 : .appMediumTitle3)
						.foregroundColor(isAboutUs ? K.Colors.firstColorDark : .black)
						.multilineTextAlignment(.leading)
						.padding(.leading, UIDimensions.normal.spacing)
						.padding(.bottom, 5) // small is to big
					
					Text(description ?? "")
						.font(.appRegularTitle4)
						.foregroundColor(.black)
						.multilineTextAlignment(.leading)
						.padding(.leading, UIDimensions.normal.spacing)
				}
				Spacer()
				ImageView(
					url: photoUrl,
					contentMode: .fill
				)
				.frame(width: 90, height: 90)
				.cornerRadius(8, corners: [.topRight, .bottomRight])
			}
		}
		.frame(height: 92)
		.foregroundColor(K.CellColors.scienceBackground)
		.cornerRadius(8)
        .padding([.leading, .trailing])
    }
}
