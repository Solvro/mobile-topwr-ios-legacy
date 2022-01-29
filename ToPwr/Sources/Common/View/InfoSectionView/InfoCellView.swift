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
                        .shadow(.down, radius: 1)
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
            ZStack {
                switch info.type {
                case .phone:
                    Link(
                        info.label ?? info.value ?? "",
                        destination: URL(string: "tel:\(info.value!)")!
                    )
                case .addres:
                    Text(info.label ?? "")
                        
                case .website:
                    Link(
                        info.label ?? info.value ?? "",
                        destination: URL(string: info.value!)!
                    )
                case .email:
                    Link(
                        info.label ?? info.value ?? "",
                        destination: URL(string: "mailto:\(info.value!)")!
                    )
                case .other:
                    Text(info.label ?? "")
                        .underline()
                }
            }
            .foregroundColor(K.Colors.red)
            .verticalPadding(.normal)
        }
        .horizontalPadding(.normal)
    }
}
