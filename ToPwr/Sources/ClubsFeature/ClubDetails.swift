import Foundation
import SwiftUI
import Common
import ComposableArchitecture

//MARK: - STATE
public struct ClubDetailsState: Equatable, Identifiable {
    public let id: UUID
    let club: ScienceClub
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
}

//MARK: - ENVIRONMENT
public struct ClubDetailsEnvironment {
    public init () {}
}

//MARK: - REDUCER
public let clubDetailsReducer = Reducer<
    ClubDetailsState,
    ClubDetailsAction,
    ClubDetailsEnvironment
> { state, action, env in
    switch action {
    case .onAppear:
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
                VStack {
                    ImageView(
                        url: URL(string: viewStore.club.background?.url ?? ""),
                        contentMode: .aspectFill
                    )
                        .frame(height: Constants.backgroundImageHeith)
                    
                    ImageView(
                        url: URL(string: viewStore.club.photo?.url ?? ""),
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
                    
                    Text("TODO: Wydział")
                        .font(.appRegularTitle2)
                        .horizontalPadding(.huge)
                    
                    if !viewStore.club.contact.isEmpty {
                        ZStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(Strings.Other.contact)
                                        .font(.appBoldTitle2)
                                        .horizontalPadding(.normal)
                                    Spacer()
                                }
                                VStack {
                                    ForEach(viewStore.club.contact) { contact in
                                        ContactView(contact: contact)
                                    }
                                }
                            }
                        }
                        .verticalPadding(.normal)
                        .background(K.Colors.lightGray)
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
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
