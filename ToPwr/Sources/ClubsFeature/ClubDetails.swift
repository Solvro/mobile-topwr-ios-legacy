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
                        .frame(height: 300)
                    
                    ImageView(
                        url: URL(string: viewStore.club.photo?.url ?? ""),
                        contentMode: .aspectFill
                    )
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .shadow(radius: 7, x: 0, y: -5)
                        .offset(y: -60)
                        .padding(.bottom, -60)
                    
                    Text(viewStore.club.name ?? "")
                        .font(.appBoldTitle2)
                        .horizontalPadding(.big)
                    
                    Text(viewStore.club.locale)
                        .font(.appRegularTitle2)
                        .horizontalPadding(.huge)
                    
                    ZStack {
                        VStack {
                            Text(Strings.Other.deanOffice)
                                .font(.appBoldTitle2)
                        }
                        HStack {
                            Text(viewStore.club.contact.first?.name ?? "")
                        }
                    }
                    .background(K.Colors.lightGray)
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
