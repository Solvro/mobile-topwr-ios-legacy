import SwiftUI
import ComposableArchitecture
import Common

public struct ClubCellView: View {
    let viewState: ClubDetails.State
    
    public init(viewState: ClubDetails.State) {
        self.viewState = viewState
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            K.CellColors.scienceBackground
            HStack {
                HStack {
                    Text(viewState.club.name ?? "")
                        .font(.appMediumTitle3)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, UIDimensions.normal.spacing)
                }
                HStack {
                    Spacer()
                    ZStack {
                        ImageView(
                            url: viewState.club.photo?.url,
                            contentMode: .aspectFill
                        )
                            .frame(width: 90, height: 90)
                            .cornerRadius(8, corners: [.topRight, .bottomRight])
                    }
                }
            }
        }
        .frame(height: 92)
        .foregroundColor(K.CellColors.scienceBackground)
        .cornerRadius(8)
        .padding([.leading, .trailing])
    }
}

// TODO: - Implement mock
