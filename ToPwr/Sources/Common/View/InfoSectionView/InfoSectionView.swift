import SwiftUI

public struct InfoSectionView: View {
	let section: InfoSection
	
	public init(
		section: InfoSection
	){
		self.section = section
	}
	
	public var body: some View {
		ZStack {
			VStack(alignment: .leading) {
				HStack {
					Text(section.name ?? "")
						.font(.appMediumTitle3)
						.horizontalPadding(.normal)
					Spacer()
				}
				ForEach(section.info) { info in
					switch info.type {
					case .other, .addres:
						InfoCellView(info: info)
					case .website:
						if let safeURL = info.getValueUrl() {
							Link(
								destination: safeURL,
								label: {
									InfoCellView(info: info)
								}
							)
						}
					default:
						if let safeUrl = info.getValueUrl() {
							Link(
								destination: safeUrl,
								label: {
									InfoCellView(info: info)
								}
							)
						}
					}
				}
			}
		}
		.onAppear{
			print(section.info)
		}
		.verticalPadding(.normal)
		.background(K.Colors.lightGray)
	}
}
