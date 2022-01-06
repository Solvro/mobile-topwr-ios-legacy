import SwiftUI
import ComposableArchitecture
import Common

public struct DepartmentCellView: View {
    let viewState: DepartmentDetailsState
    
    public init(
        state: DepartmentDetailsState
    ) {
        self.viewState = state
    }
    
    public var body: some View {
        ZStack(alignment: .leading) {
            BanerView(
                url: URL(string: viewState.department.logo?.url ?? ""),
                color: viewState.department.color
            )
                .frame(width: 360, height: 120)
                .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(viewState.department.code ?? "")
                    .bold()
                    .font(.appBoldTitle3)
                    .padding(.bottom, 10)
                
                Text(viewState.department.name ?? "")
                    .font(.appRegularTitle3)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .foregroundColor(.white)
            .padding([.top, .bottom, .leading], 15)
        }
    }
}
