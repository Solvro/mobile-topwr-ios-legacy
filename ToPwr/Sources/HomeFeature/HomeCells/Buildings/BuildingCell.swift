import SwiftUI
import ComposableArchitecture
import Common

public struct BuildingCell: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable, Identifiable {
        public let id: Int
        let building: Map
        
        public init(building: Map) {
            self.id = building.id
            self.building = building
        }
    }
    
    // MARK: - Action
    public enum Action: Equatable {
        case buttonTapped
    }
    
    // MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        EmptyReducer()
    }
}

//MARK: - VIEW
public struct BuildingCellView: View {
    let store: StoreOf<BuildingCell>
    
    public init(store: StoreOf<BuildingCell>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            Button(action: {
                viewStore.send(.buttonTapped)
            }, label: {
                ZStack(alignment: .bottomLeading) {
                    ImageView(
                        url: viewStore.building.photo?.url,
                        contentMode: .aspectFill
                    )
                    
                    LinearGradient(
                        colors: [Color.black.opacity(0.4), Color.black.opacity(0)],
                        startPoint: .bottom,
                        endPoint: .center
                    )
                    
                    Text(viewStore.building.code ?? "")
                        .font(.appMediumTitle2)
                        .foregroundColor(.white)
                        .padding()
                }
                .cornerRadius(8)
            }) .frame(width: 120, height: 120)
        }
    }
}

#if DEBUG
// MARK: - Mock
extension BuildingCell.State {
    static let mock: Self = .init(building: .mock)
}

// MARK: - Preview
private struct BuildingCellView_Preview: PreviewProvider {
    static var previews: some View {
        BuildingCellView(
            store: .init(
                initialState: .mock,
                reducer: BuildingCell()
            )
        )
    }
}

#endif
