import ComposableArchitecture
import Combine
import SwiftUI
import Common
import IdentifiedCollections
import ClubsFeature

public struct DepartmentDetails: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable, Identifiable {
        public let id: UUID
        public let department: Department
        var clubs: IdentifiedArrayOf<ClubDetails.State> = .init(uniqueElements: [])
        var clubDetailsState: ClubDetails.State?
        var isClubDetailsActive: Bool = false
        
        public init(
            id: UUID = UUID(),
            department: Department
        ) {
            self.id = id
            self.department = department
        }
    }
    
    public init() {}
    
    // MARK: - Action
    public enum Action: Equatable {
        case onAppear
        case getClubs
        case loadClub(Int)
        case receivedClub(TaskResult<ScienceClub>)
        case clubAction(ClubDetails.Action)
        case isClubDetailsActive(Bool)
        case clubTapped(ClubDetails.State?)
    }
    
    // MARK: - Dependencies
    @Dependency(\.departments) var departmentsClient
    
    // MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .task { .getClubs }
            case .getClubs:
                return .run { [clubsID = state.department.clubsID] send in
                    for id in clubsID {
                        await send(.loadClub(id))
                    }
                }
            case .loadClub(let id):
                return .task {
                    await .receivedClub(TaskResult {
                        try await departmentsClient.getScienceClub(id)
                    })
                }
            case .receivedClub(.success(let club)):
                let clubs = state.clubs
                if !clubs.contains(where: { $0.club.id == club.id }) {
                    state.clubs.append(
                        ClubDetails.State(
                            club: club,
                            department: state.department
                        )
                    )
                }
                return .none
            case .receivedClub(.failure):
                return .none
            case .clubAction:
                return .none
            case .isClubDetailsActive(let active):
                state.isClubDetailsActive = active
                return .none
            case .clubTapped(let club):
                if let club = club {
                    state.clubDetailsState = club
                    return .task { .isClubDetailsActive(true) }
                } else {
                    state.isClubDetailsActive = false
                    return .task { .isClubDetailsActive(false) }
                }
            }
        }
        .ifLet(\.clubDetailsState, action: /Action.clubAction) {
            ClubDetails()
        }
    }
}

// MARK: - View
public struct DepartmentDetailsView: View {
    private enum Constants {
        static let backgroundImageHeith: CGFloat = 254
        static let logoBackgroundSize: CGFloat = 120
        static let logoSize: CGFloat = 64
        static let fieldsHeight: CGFloat = 50
    }
    
    let store: StoreOf<DepartmentDetails>
    
    public init(store: StoreOf<DepartmentDetails>) {
        self.store = store
    }
    
    // MARK: - View State
    
    private struct ViewState: Equatable {
        let latitude: Float?
        let longitude: Float?
        let logoUrl: URL?
        let color: GradientColor?
        let name: String?
        let adress: String?
        let infoSection: [InfoSection]
        let fieldOfStudy: [FieldOfStudy]
        let clubs: IdentifiedArrayOf<ClubDetails.State>
        var clubDetailsState: ClubDetails.State?
        var isClubDetailsActive: Bool = false
        
        init(state: DepartmentDetails.State) {
            self.latitude = state.department.latitude
            self.longitude = state.department.longitude
            self.logoUrl = state.department.logo?.url
            self.color = state.department.color
            self.name = state.department.name
            self.adress = state.department.adress
            self.infoSection = state.department.infoSection
            self.fieldOfStudy = state.department.fieldOfStudy
            self.clubs = state.clubs
            self.clubDetailsState = state.clubDetailsState
            self.isClubDetailsActive = state.isClubDetailsActive
        }
    }
    
    public var body: some View {
        WithViewStore(store.scope(state: ViewState.init)) { viewStore in
            ScrollView {
                VStack {
                    DetailsMapView(
                        lat: viewStore.latitude,
                        lon: viewStore.longitude
                    )
                    .frame(height: Constants.backgroundImageHeith)
                    
                    LogoView(
                        url: viewStore.logoUrl,
                        color: viewStore.color,
                        backgroundSize: Constants.logoBackgroundSize,
                        logoSize: Constants.logoSize
                    )
                    .offset(y: -(Constants.logoBackgroundSize/2))
                    .padding(.bottom, -(Constants.logoBackgroundSize/2))
                    
                    if let departmentName = viewStore.name {
                        Text(departmentName)
                            .font(.appMediumTitle2)
                            .horizontalPadding(.big)
                    }
                    
                    if let departmentAdress = viewStore.adress {
                        Text(departmentAdress)
                            .font(.appRegularTitle4)
                            .horizontalPadding(.huge)
                            .multilineTextAlignment(.center)
                    }
                    
                    ForEach(viewStore.infoSection) { section in
                        VStack(spacing: UIDimensions.normal.spacing) {
                            InfoSectionView(
                                section: section
                            )
                        }
                    }
                    
                    VStack {
                        HStack {
                            Text(Strings.Other.fields)
                                .font(.appMediumTitle3)
                            Spacer()
                        }
                        .verticalPadding(.normal)
                        
                        VStack {
                            ForEach(viewStore.fieldOfStudy) { department in
                                FieldView(
                                    title: department.name2 ?? "",
                                    height: Constants.fieldsHeight
                                )
                            }
                        }
                    }
                    .horizontalPadding(.normal)
                    
                    VStack {
                        HStack {
                            Text(Strings.HomeLists.scienceClubsTitle)
                                .font(.appMediumTitle3)
                            Spacer()
                        }
                        .padding(.normal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewStore.clubs) { club in
                                    Button(
                                        action: {
                                            viewStore.send(.clubTapped(club))
                                        },
                                        label: {
                                            ClubCellView(viewState: club)
                                        }
                                    )
                                }
                                .horizontalPadding(.normal)
                            }
                            .verticalPadding(.normal)
                        }
                        
                    }
                    .onAppear {
                        viewStore.send(.onAppear)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                }
                .sheet(
                    isPresented: Binding(
                        get: { viewStore.isClubDetailsActive },
                        set: { viewStore.send(.isClubDetailsActive($0)) }
                    )
                ) {
                    IfLetStore(
                        self.store.scope(
                            state: {
                                print($0.clubDetailsState)
                                return $0.clubDetailsState
                            },
                            action: DepartmentDetails.Action.clubAction
                        ),
                        then: ClubDetailsView.init(store:),
                        else: ProgressView.init
                    )
                }
            }
        }
    }
        
    //MARK: LogoView
    struct LogoView: View {
        let url: URL?
        let color: GradientColor?
        let backgroundSize: CGFloat
        let logoSize: CGFloat
        
        public var body: some View {
            ZStack {
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            color?.secondColor ?? K.Colors.firstColorLight,
                            color?.firstColor ?? K.Colors.firstColorDark
                        ]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(
                    width: backgroundSize,
                    height: backgroundSize
                )
                
                ImageView(
                    url: url,
                    contentMode: .aspectFit
                )
                .frame(
                    width: logoSize,
                    height: logoSize
                )
            }
            .clipShape(Circle())
            .shadow(.down)
            
        }
    }
    
    //MARK: Field View
    struct FieldView: View {
        let title: String
        let height: CGFloat
        var body: some View {
            HStack {
                Text(title)
                    .font(.appMediumTitle3)
                    .horizontalPadding(.big)
                Spacer()
            }
            .frame(height: height)
            .background(K.Colors.lightGray)
            .cornerRadius(UIDimensions.normal.cornerRadius)
        }
    }
}

#if DEBUG
// MARK: - Mock
extension DepartmentDetails.State {
    static let mock: Self = .init(department: .mock)
}

// MARK: - Preview
private struct DepartmentDetailsView_Preview: PreviewProvider {
    static var previews: some View {
        DepartmentDetailsView(
            store: .init(
                initialState: .mock,
                reducer: DepartmentDetails()
            )
        )
    }
}

#endif
