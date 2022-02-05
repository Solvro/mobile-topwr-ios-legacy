import SwiftUI
import ComposableArchitecture
import Common

public struct DepartmentCellView: View {
    
    enum Constants {
        static let banerWidth: CGFloat = 360
        static let banerHeight: CGFloat = 120
        enum Home {
            static let banerWidth: CGFloat = 183
            static let banerHeight: CGFloat = 162
        }
    }
    
    let viewState: DepartmentDetailsState
    let isHomeCell: Bool
    
    public init(
        state: DepartmentDetailsState,
        isHomeCell: Bool = false
    ) {
        self.viewState = state
        self.isHomeCell = isHomeCell
    }
    
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            BanerView(
                url: viewState.department.logo?.url,
                color: viewState.department.color,
                isSquare: isHomeCell
            )
                .frame(
                    width: isHomeCell ? Constants.Home.banerWidth : Constants.banerWidth,
                    height: isHomeCell ? Constants.Home.banerHeight : Constants.banerHeight
                )
                .cornerRadius(UIDimensions.normal.cornerRadius)
            VStack(alignment: .leading) {
                Text(viewState.department.code ?? "")
                    .bold()
                    .font(.appBoldTitle3)
                    .padding(.bottom, 10)
                
                Text(viewState.department.name ?? "")
                    .font(.appRegularTitle3)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if !isHomeCell { Spacer() }
            }
            .foregroundColor(.white)
            .padding()
        }
        .frame(maxWidth: isHomeCell ? Constants.Home.banerWidth : Constants.banerWidth)
    }
}
