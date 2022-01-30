import SwiftUI
import Nuke
import NukeUI

///This struct returns view which contains logo with gradient on the background.
///Logo is transparent 10% and offset depends on square
public struct BanerView: View {
    let url: URL?
    let color: GradientColor?
    let isSquare: Bool
    
    public init(
        url: URL?,
        color: GradientColor?,
        isSquare: Bool = false
    ) {
        self.url = url
        self.color = (
            color == nil ||
            color?.gradientFirst == nil ||
            color?.gradientSecond == nil
        ) ? K.defaultGradient : color
        self.isSquare = isSquare
    }
    
    public var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        color?.secondColor ?? K.Colors.firstColorLight,
                        color?.firstColor ?? K.Colors.firstColorDark
                    ]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            ImageView(
                url: url,
                contentMode: .aspectFit
            )
            .opacity(0.1)
            .offset(
                x: isSquare ? 0 : 90,
                y: isSquare ? 0 : 0
            )
            .aspectRatio(
                isSquare ? 1 : 2.9,
                contentMode: .fill
            )
        }
    }
}
