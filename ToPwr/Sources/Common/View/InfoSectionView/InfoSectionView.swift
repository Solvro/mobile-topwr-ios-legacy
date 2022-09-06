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
						if let safeURL = URL(string: info.value ?? info.label ?? "") {
							Link(
								destination: safeURL,
								label: {
									InfoCellView(info: info)
								}
							)
						}
					case .phone:
						if let safeUrl = URL(string: "tel:\(info.value ?? info.label ?? "")")!{
							Link(
								destination: safeUrl,
								label: {
									InfoCellView(info: info)
								}
							)
						}
					case .email:
						if let safeUrl = URL(string: "mailto:\(info.value ?? info.label ?? "")")!{
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
		.verticalPadding(.normal)
		.background(K.Colors.lightGray)
	}
}
