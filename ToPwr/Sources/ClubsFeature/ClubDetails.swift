import Foundation
import SwiftUI
import Common
import ComposableArchitecture
import Combine

//MARK: - STATE
public struct ClubDetailsState: Equatable, Identifiable {
    public let id: UUID
    let club: ScienceClub
    var department: Department?
    var isLoading: Bool = true
    
    public init(
        id: UUID = UUID(),
        club: ScienceClub
    ){
        self.id = id
        self.club = club
    }
}
//MARK: - ACTION
public enum ClubDetailsAction: Equatable {
    case onAppear
    case loadDepartment(Int)
    case resultDepartment(Result<Department, ErrorModel>)
}

//MARK: - ENVIRONMENT
public struct ClubDetailsEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getDepartment: (Int) -> AnyPublisher<Department, ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getDepartment: @escaping (Int) -> AnyPublisher<Department, ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getDepartment = getDepartment
    }
}

//MARK: - REDUCER
public let clubDetailsReducer = Reducer<
    ClubDetailsState,
    ClubDetailsAction,
    ClubDetailsEnvironment
> { state, action, env in
    switch action {
    case .onAppear:
        return .init(
            value: .loadDepartment(
                state.club.department
            )
        )
    case .loadDepartment(let id):
        return env.getDepartment(id)
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map(ClubDetailsAction.resultDepartment)
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
//MARK: - VIEW
public struct ClubDetailsView: View {
    
    private enum Constants {
        static let backgroundImageHeith: CGFloat = 254
        static let avatarSize: CGFloat = 120
    }
    
    let store: Store<ClubDetailsState, ClubDetailsAction>
    
    public init(
        store: Store<ClubDetailsState, ClubDetailsAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                if viewStore.isLoading {
                    ProgressView()
                } else {
                    VStack {
                        ImageView(
                            url: viewStore.club.background?.url,
                            contentMode: .aspectFill
                        )
                            .frame(height: Constants.backgroundImageHeith)
                        
                        ImageView(
                            url: viewStore.club.photo?.url,
                            contentMode: .aspectFill
                        )
                            .frame(
                                width: Constants.avatarSize,
                                height: Constants.avatarSize
                            )
                            .clipShape(Circle())
                            .shadow(radius: 7, x: 0, y: -5)
                            .offset(y: -(Constants.avatarSize/2))
                            .padding(.bottom, -(Constants.avatarSize/2))
                        
                        Text(viewStore.club.name ?? "")
                            .font(.appBoldTitle2)
                            .horizontalPadding(.big)
                        
                        if let departmentName = viewStore.department?.name {
                            Text(departmentName)
                                .font(.appRegularTitle2)
                                .horizontalPadding(.huge)
                        }
                        
                        if !viewStore.club.socialMedia.isEmpty {
//                            LinkSection(
//                                title: "Social Media",
//                                links: viewStore.club.socialMedia
//                            )
                        }
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text(Strings.Other.aboutUs)
                                    .font(.appBoldTitle2)
                                Spacer()
                            }
                            
                            Text(viewStore.club.description ?? "")
                                .font(.appRegularTitle2)
                            
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
