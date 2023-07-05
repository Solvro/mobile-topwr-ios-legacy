import SwiftUI
import ComposableArchitecture
import Common

public struct BuildingList: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        let title: String = Strings.HomeLists.buildingListTitle
        let buttonText: String = Strings.HomeLists.buildingListButton
        public var buildings: IdentifiedArrayOf<BuildingCell.State> = []
        
        var isLoading: Bool {
            buildings.isEmpty ? true : false
        }
        
        public init(buildings: [BuildingCell.State] = []) {
            self.buildings = .init(uniqueElements: buildings)
        }
    }
    
    // MARK: - Action
    public enum Action: Equatable {
        case buttonTapped
        case listButtonTapped
        case cellAction(id: BuildingCell.State.ID, action: BuildingCell.Action)
    }
    
    // MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        EmptyReducer()
            .forEach(
                \.buildings,
                 action: /Action.cellAction
            ) {
                BuildingCell()
            }
    }
}

//MARK: - VIEW
public struct BuildingListView: View {
    let store: StoreOf<BuildingList>
    
    public init(store: StoreOf<BuildingList>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Text(viewStore.title)
                    .font(.appMediumTitle2)
                    .foregroundColor(K.FontColors.primary)
                Spacer()
                Button {
                    viewStore.send(.listButtonTapped)
                } label: {
                    Text(viewStore.buttonText)
                        .foregroundColor(K.Colors.red)
                        .font(.appRegularTitle3)
                    Image(systemName: "chevron.right")
                        .foregroundColor(K.Colors.red)
                }
            }
            .horizontalPadding(.normal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 18) {
                    ForEachStore(
                        self.store.scope(
                            state: \.buildings,
                            action: BuildingList.Action.cellAction(id:action:)
                        )
                    ) { store in
                        BuildingCellView(store: store)
                    }
                }
                .horizontalPadding(.normal)
            }
        }
    }
}

#if DEBUG
// MARK: - Mock
extension BuildingList.State {
    static let mock: Self = .init()
}

// MARK: - Preview
private struct BuildingListView_Preview: PreviewProvider {
    static var previews: some View {
        BuildingListView(
            store: .init(
                initialState: .mock,
                reducer: BuildingList()
            )
        )
    }
}

#endif
