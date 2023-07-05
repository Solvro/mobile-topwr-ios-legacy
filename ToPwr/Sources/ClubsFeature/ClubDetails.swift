import Foundation
import SwiftUI
import Common
import ComposableArchitecture
import Combine

public struct ClubDetails: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable, Identifiable {
        public let id: UUID
        public let club: ScienceClub
        var department: Department?
        var isLoading: Bool = true
        
        public init(
            id: UUID = UUID(),
            club: ScienceClub,
            department: Department? = nil
        ){
            self.id = id
            self.club = club
            self.department = department
        }
    }
    
    public init() {}
    
    // MARK: - Action
    public enum Action: Equatable {
        case onAppear
        case loadDepartment(Int)
        case resultDepartment(TaskResult<Department>)
    }
    
    // MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard let clubDepartment = state.department else {
                    guard let departmentID = state.club.department else {
                        state.isLoading = false
                        return .none
                    }
                    return .init(
                        value: .loadDepartment(
                            departmentID
                        )
                    )
                }
                state.isLoading = false
                return .none
            case .loadDepartment(let id):
                // TODO: - Implement department loading
//                return env.getDepartment(id)
//                    .receive(on: env.mainQueue)
//                    .catchToEffect()
//                    .map(ClubDetailsAction.resultDepartment)
                return .none
            case .resultDepartment(.success(let department)):
                state.department = department
                state.isLoading = false
                return .none
            case .resultDepartment(.failure(let error)):
                print(error.localizedDescription)
                state.isLoading = false
                return .none
            }
        }
    }
}

//MARK: - VIEW
public struct ClubDetailsView: View {
    
    private enum Constants {
        static let backgroundImageHeith: CGFloat = 254
        static let avatarSize: CGFloat = 120
    }
    
    let store: StoreOf<ClubDetails>
    
    public init(store: StoreOf<ClubDetails>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                if viewStore.isLoading {
                    ProgressView()
                } else {
                    VStack {
                        ImageView(url: viewStore.club.background?.url, contentMode: .aspectFill)
                            .frame(height: Constants.backgroundImageHeith)
                        
                        ImageView(url: viewStore.club.photo?.url, contentMode: .aspectFill)
                            .frame(width: Constants.avatarSize, height: Constants.avatarSize)
                            .clipShape(Circle())
                            .shadow(radius: 7, x: 0, y: -5)
                            .offset(y: -(Constants.avatarSize/2))
                            .padding(.bottom, -(Constants.avatarSize/2))
                        
                        Text(viewStore.club.name ?? "")
                            .font(.appMediumTitle2)
                            .horizontalPadding(.big)
                        
                        if let departmentName = viewStore.department?.name {
                            Text(departmentName)
                                .font(.appRegularTitle4)
                                .horizontalPadding(.huge)
                        }
                        
                        ForEach(viewStore.club.infoSection) { section in
                            VStack(spacing: UIDimensions.normal.spacing) {
                                InfoSectionView(section: section)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text(Strings.Other.aboutUs)
                                    .font(.appMediumTitle3)
                                Spacer()
                            }.padding(.bottom, 10)
                            
                            Text(viewStore.club.description ?? "")
                                .font(.appRegularTitle4)
                            
                        }
                        .verticalPadding(.normal)
                        .horizontalPadding(.normal)
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#if DEBUG
// MARK: - Mock
extension ClubDetails.State {
    static let mock: Self = .init(club: .mock)
}

// MARK: - Preview
private struct ClubDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ClubDetailsView(
            store: .init(initialState: .mock, reducer: ClubDetails())
        )
    }
}

#endif
