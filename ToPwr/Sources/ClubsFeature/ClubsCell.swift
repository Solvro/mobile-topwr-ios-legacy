import SwiftUI
import ComposableArchitecture
import Common

//MARK: - STATE
public struct ClubCellState: Equatable, Identifiable {
    public let id: String
    var club: ScienceClub

    public init(
        club: ScienceClub
    ){
        self.id = UUID().uuidString
        self.club = club
    }
}
//MARK: - ACTION
public enum ClubCellAction: Equatable {
    case buttonTapped
}

//MARK: - ENVIRONMENT
public struct ClubCellEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let ClubCellReducer = Reducer<
    ClubCellState,
    ClubCellAction,
    ClubCellEnvironment
> { state, action, environment in
    switch action {
    case .buttonTapped:
        print("Club Cell Tapped")
        return .none
    }
}

//MARK: - VIEW
public struct ClubCellView: View {
    let store: Store<ClubCellState, ClubCellAction>
    
    public init(
        store: Store<ClubCellState, ClubCellAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            Button(action: {
                viewStore.send(.buttonTapped)
            }, label: {
                ZStack(alignment: .topLeading) {
//                    Rectangle()
//                        .foregroundColor(K.CellColors.scienceBackground)
//                        .cornerRadius(8)
                    HStack() {
                        HStack() {
                            Text(viewStore.club.name ?? "")
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                        }
                        HStack() {
                            Spacer()
                            ZStack() {
//                                Rectangle()
//                                    .frame(width: 72, height: 72)
//                                    .foregroundColor(.white)
//                                    .cornerRadius(8)
                                ImageView(
                                    url: URL(string: viewStore.club.photo?.url ?? ""),
                                    contentMode: .aspectFill
                                )
                                .frame(width: 59, height: 59)
                                .cornerRadius(8, corners: [.topRight, .bottomRight])
                            }
                            .background(Color.red)
                        }
                    }
                    .padding()
                }
                .frame(height:20)
                .foregroundColor(K.CellColors.scienceBackground)
                .cornerRadius(8)
                .padding([.leading, .trailing])
            })
        }
    }
}

//MARK: - MOCKS & PREVIEW
#if DEBUG
public extension ClubCellState {
    static let mock: Self = .init(
        club: .mock
    )
}
#endif
