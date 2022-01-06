import SwiftUI

public extension View {
    
    func padding(_ dimension: UIDimensions) -> some View {
        self.padding(dimension.padding)
    }
    
    func verticalPadding(_ dimension: UIDimensions) -> some View {
        self.padding(dimension.verticalPadding)
    }
    
    func horizontalPadding(_ dimension: UIDimensions) -> some View {
        self.padding(dimension.horizontalPadding)
    }
}

public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
    func barLogo() -> some View {
        self.toolbar { ToolbarItem(placement: .navigationBarLeading) {
            HStack {
                LogoView()
                    .aspectRatio(contentMode: .fit)
                Spacer()
            }
            .frame(height: 19)
            .verticalPadding(.small)
            .horizontalPadding(.small)
        }
        }
    }
}

public struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
