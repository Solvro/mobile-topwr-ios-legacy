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
                        .font(.appBoldTitle2)
                        .horizontalPadding(.normal)
                    Spacer()
                }
                ForEach(section.info) { info in
                    if let _ = info.value {
                        InfoCellView(info: info)
                    }
                }
            }
        }
        .verticalPadding(.normal)
        .background(K.Colors.lightGray)
    }
}
