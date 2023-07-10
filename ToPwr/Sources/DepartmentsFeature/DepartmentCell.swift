import SwiftUI
import ComposableArchitecture
import Common

public struct DepartmentCellView: View {
    
    enum Constants {
        static let banerWidth: CGFloat = 360
        static let banerHeight: CGFloat = 92
        enum Home {
            static let banerWidth: CGFloat = 120
            static let banerHeight: CGFloat = 120
        }
    }
    
    let viewState: DepartmentDetails.State
    let isHomeCell: Bool
    
    public init(
        state: DepartmentDetails.State,
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
                    .font(.appMediumTitle3)
                    .padding(.bottom, 5)
                
                Text(viewState.department.name ?? "")
                    .font(.appRegularTitle4)
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
