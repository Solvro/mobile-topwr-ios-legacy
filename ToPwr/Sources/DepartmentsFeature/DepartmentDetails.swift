import ComposableArchitecture
import Combine
import SwiftUI
import Common
import IdentifiedCollections
import ClubsFeature

// MARK: - State
public struct DepartmentDetailsState: Equatable, Identifiable {
    public let id: UUID
    public let department: Department
    var clubs: IdentifiedArrayOf<ClubDetailsState> = .init(uniqueElements: [])
    var clubDetailsState: ClubDetailsState?
    var isClubDetailsActive: Bool = false
    
    public init(
        id: UUID = UUID(),
        department: Department
    ) {
        self.id = id
        self.department = department
    }
}

extension DepartmentDetailsState {
    struct ViewState: Equatable {
        let latitude: Float?
        let longitude: Float?
        let logoUrl: URL?
        let color: GradientColor?
        let name: String?
        let adress: String?
        let infoSection: [InfoSection]
        let fieldOfStudy: [FieldOfStudy]
        let clubs: IdentifiedArrayOf<ClubDetailsState>
        var clubDetailsState: ClubDetailsState?
        var isClubDetailsActive: Bool = false
    }
    
    var viewState: ViewState {
        ViewState(
            latitude: self.department.latitude,
            longitude: self.department.longitude,
            logoUrl: self.department.logo?.url,
            color: self.department.color,
            name: self.department.name,
            adress: self.department.adress,
            infoSection: self.department.infoSection,
            fieldOfStudy: self.department.fieldOfStudy,
            clubs: self.clubs,
            clubDetailsState: self.clubDetailsState,
            isClubDetailsActive: self.isClubDetailsActive
        )
    }
    
}

// MARK: - Actions
public enum DepartmentDetailsAction: Equatable {
    case onAppear
    case getClubs
    case loadClub(Int)
    case receivedClub(Result<ScienceClub, ErrorModel>)
    case clubAction(ClubDetailsAction)
    case isClubDetailsActive(Bool)
    case clubTapped(ClubDetailsState?)
}

// MARK: - Environment
public struct DepartmentDetailsEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getScienceClub: (Int) -> AnyPublisher<ScienceClub, ErrorModel>
    let getDepartment: (Int) -> AnyPublisher<Department, ErrorModel>
    
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getScienceClub: @escaping (Int) -> AnyPublisher<ScienceClub, ErrorModel>,
        getDepartment: @escaping (Int) -> AnyPublisher<Department, ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getScienceClub = getScienceClub
        self.getDepartment = getDepartment
    }
}

// MARK: - Reducer
public let departmentDetailsReducer = Reducer<
    DepartmentDetailsState,
    DepartmentDetailsAction,
    DepartmentDetailsEnvironment
> { state, action, env in
    switch action {
    case .onAppear:
        return .init(value: .getClubs)
    case .getClubs:
        var actions: [Effect<DepartmentDetailsAction, Never>] = []
        for id in state.department.clubsID {
            actions.append(.init(value: .loadClub(id)))
        }
        return .concatenate(actions)
    case .loadClub(let id):
        return env.getScienceClub(id)
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map(DepartmentDetailsAction.receivedClub)
    case .receivedClub(.success(let club)):
        let clubs = state.clubs
        if !clubs.contains(where: { $0.club.id == club.id }) {
            state.clubs.append(
                ClubDetailsState(
                    club: club,
                    department: state.department
                )
            )
        }
        return .none
    case .receivedClub(.failure(let error)):
        print(error)
        return .none
    case .clubAction:
        return .none
    case .isClubDetailsActive(let active):
        state.isClubDetailsActive = active
        return .none
    case .clubTapped(let club):
        if let club = club {
            state.clubDetailsState = club
            return .init(value: .isClubDetailsActive(true))
        } else {
            state.isClubDetailsActive = false
            return .init(value: .isClubDetailsActive(false))
        }
    }
}
.combined(
    with: clubDetailsReducer
        .optional()
        .pullback(
            state: \.clubDetailsState,
            action: /DepartmentDetailsAction.clubAction,
            environment: { env in
                ClubDetailsEnvironment(
                    mainQueue: env.mainQueue,
                    getDepartment: env.getDepartment
                )
            }
        )
)

// MARK: - View
public struct DepartmentDetailsView: View {
    private enum Constants {
        static let backgroundImageHeith: CGFloat = 254
        static let logoBackgroundSize: CGFloat = 120
        static let logoSize: CGFloat = 64
        static let fieldsHeight: CGFloat = 50
    }
    
    let store: Store<DepartmentDetailsState, DepartmentDetailsAction>
    
    public init(store: Store<DepartmentDetailsState, DepartmentDetailsAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store.scope(state: \.viewState)) { viewStore in
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
                            action: DepartmentDetailsAction.clubAction
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

//MARK: - Mocks
#if DEBUG

public extension DepartmentDetailsEnvironment {
    static let failing: Self = .init(
        mainQueue: .immediate,
        getScienceClub: failing1,
        getDepartment: failing1
    )
}
#endif
