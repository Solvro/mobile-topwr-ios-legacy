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
                            Link(
                                destination: URL(
                                    string: info.value ?? info.label ?? ""
                                )!,
                                label: {
                                    InfoCellView(info: info)
                                }
                            )
                        case .phone:
                            Link(
                                destination: URL(
                                    string: "tel:\(info.value ?? info.label ?? "")"
                                )!,
                                label: {
                                    InfoCellView(info: info)
                                }
                            )
                        case .email:
                            Link(
                                destination: URL(
                                    string: "mailto:\(info.value ?? info.label ?? "")"
                                )!,
                                label: {
                                    InfoCellView(info: info)
                                }
                            )
                        }
                }
            }
        }
        .verticalPadding(.normal)
        .background(K.Colors.lightGray)
    }
}
