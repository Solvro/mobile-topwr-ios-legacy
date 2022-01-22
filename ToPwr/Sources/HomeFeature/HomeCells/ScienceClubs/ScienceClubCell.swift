import SwiftUI
import ComposableArchitecture
import Common

//MARK: - STATE
public struct ScienceClubCellState: Equatable, Identifiable {
    public let id: Int
    var scienceClub: ScienceClub

    public init(
        scienceClub: ScienceClub
    ){
        self.id = scienceClub.id
        self.scienceClub = scienceClub
    }
}
//MARK: - ACTION
public enum ScienceClubCellAction: Equatable {
    case buttonTapped
}

//MARK: - ENVIRONMENT
public struct ScienceClubCellEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let scienceClubCellReducer = Reducer<
    ScienceClubCellState,
    ScienceClubCellAction,
    ScienceClubCellEnvironment
> { state, action, environment in
    switch action {
    case .buttonTapped:
        print("Science Club Cell Tapped")
        return .none
    }
}

//MARK: - VIEW
public struct ScienceClubCellView: View {
    let store: Store<ScienceClubCellState, ScienceClubCellAction>
    
    public init(
        store: Store<ScienceClubCellState, ScienceClubCellAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            Button(action: {
                viewStore.send(.buttonTapped)
            }, label: {
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .foregroundColor(K.CellColors.scienceBackground)
                        .cornerRadius(8)
                    VStack() {
                        HStack() {
                            Spacer()
                            ZStack() {
                                Rectangle()
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                                ImageView(
                                    url: viewStore.scienceClub.photo?.url,
                                    contentMode: .aspectFill
                                )
                                    .frame(width: 20, height: 20)
                            }
                        }
                        Spacer()
                        HStack() {
                            Text(viewStore.scienceClub.name ?? "")
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }.padding()
                }
                .frame(width: 183, height: 152)
            })
        }
    }
}

//MARK: - MOCKS & PREVIEW
#if DEBUG
public extension ScienceClubCellState {
    static let mock: Self = .init(
        scienceClub: .mock
    )
}
#endif
