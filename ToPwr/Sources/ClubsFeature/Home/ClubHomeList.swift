import SwiftUI
import ComposableArchitecture
import Combine
import Common

public struct ClubHomeList: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        let title: String = Strings.HomeLists.scienceClubsTitle
        let buttonText: String = Strings.HomeLists.departmentListButton
        
        var clubs: IdentifiedArrayOf<ClubDetails.State> = .init(uniqueElements: [])
        var selection: ClubDetails.State?
        var isFetching = false
        var noMoreFetches = false
        
        public init(clubs: [ClubDetails.State] = []) {
            self.clubs = .init(uniqueElements: clubs)
        }
    }
    
    public init() {}
    
    // MARK: - Action
    public enum Action: Equatable {
        case listButtonTapped
        case clubDetailsAction(ClubDetails.Action)
        case receivedClubs(TaskResult<[ScienceClub]>)
        case loadMoreClubs
        case fetchingOn
        case navigateToDetails(ClubDetails.State)
    }
    
    // MARK: - Dependency
    @Dependency(\.clubs) var clubsClient
    
    // MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .listButtonTapped:
                return .none
            case .clubDetailsAction(_):
                return .none
            case .loadMoreClubs:
                return .task { [count = state.clubs.count] in
                    await .receivedClubs(TaskResult{
                        try await clubsClient.getScienceClubs(count)
                    })
                }
            case .receivedClubs(.success(let clubs)):
                if clubs.isEmpty {
                    state.noMoreFetches = true
                    state.isFetching = false
                    return .none
                }
                clubs.forEach { state.clubs.append(ClubDetails.State(club: $0)) }
                state.isFetching = false
                return .none
            case .receivedClubs(.failure(_)):
                return .none
            case .fetchingOn:
                state.isFetching = true
                return .none
            case .navigateToDetails:
                return .none
            }
        }
        .ifLet(
            \.selection,
             action: /Action.clubDetailsAction
        ) {
            ClubDetails()
        }
    }
}

//MARK: - VIEW
public struct ClubHomeListView: View {
    let store: StoreOf<ClubHomeList>
    
    public init(store: StoreOf<ClubHomeList>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            HStack() {
                Text(viewStore.title)
                    .font(.appMediumTitle2)
                    .foregroundColor(K.FontColors.primary)
                Spacer()
                Button(
                    action: {
                        viewStore.send(.listButtonTapped)
                    },
                    label: {
                        Text(viewStore.buttonText)
                            .foregroundColor(K.Colors.red)
                            .font(.appRegularTitle3)
                        Image(systemName: "chevron.right")
                            .foregroundColor(K.Colors.red)
                    }
                )
            }
            .horizontalPadding(.normal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(viewStore.clubs) { club in
                        Button {
                            viewStore.send(.navigateToDetails(club))
                        } label: {
                            ClubHomeCellView(viewState: club)
                        }
                        .onAppear {
                            if !viewStore.noMoreFetches {
                                viewStore.send(.fetchingOn)
                                if club.id == viewStore.clubs.last?.id {
                                    viewStore.send(.loadMoreClubs)
                                }
                            }
                        }
                    }
                    if viewStore.isFetching { ProgressView() }
                }
                .horizontalPadding(.normal)
            }
        }
    }
}

#if DEBUG
// MARK: - Mock
extension ClubHomeList.State {
    static let mock: Self = .init()
}

// MARK: - Preview
private struct ClubHomeListView_Previews: PreviewProvider {
    static var previews: some View {
        ClubHomeListView(
            store: .init(
                initialState: .mock,
                reducer: ClubHomeList()
            )
        )
    }
}

#endif
