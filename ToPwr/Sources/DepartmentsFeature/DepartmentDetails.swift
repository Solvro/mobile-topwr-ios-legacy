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
    var items: IdentifiedArrayOf<TileState> = []
    //    var clubs: [ScienceClub] = []
    var clubs: IdentifiedArrayOf<ClubDetailsState> = .init(uniqueElements: [])
    var clubSelection: Identified<ClubDetailsState.ID, ClubDetailsState?>?
    
    public init(
        id: UUID = UUID(),
        department: Department
    ) {
        self.id = id
        self.department = department
    }
}

// MARK: - Actions
public enum DepartmentDetailsAction: Equatable {
    case onAppear
    case getClubs
    case loadClub(Int)
    case receivedClub(Result<ScienceClub, ErrorModel>)
    case setNavigation(selection: UUID?)
    case clubAction(ClubDetailsAction)
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
public let departmentDetailsReducer =
clubDetailsReducer
    .optional()
    .pullback(state: \Identified.value, action: .self, environment: { $0 })
    .optional()
    .pullback(
        state: \.clubSelection,
        action: /DepartmentDetailsAction.clubAction,
        environment: { env in
            ClubDetailsEnvironment(
                mainQueue: env.mainQueue,
                getDepartment: env.getDepartment
            )
        })
    .combined(
        with:Reducer<
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
                //                print("LOAD SCIENCE CLUB: \(id)")
                return env.getScienceClub(id)
                    .receive(on: env.mainQueue)
                    .catchToEffect()
                    .map(DepartmentDetailsAction.receivedClub)
            case .receivedClub(.success(let club)):
                state.clubs.append(ClubDetailsState(club: club, department: state.department))
                state.items.updateOrAppend(
                    .init(
                        id: club.id,
                        imageURL: club.photo?.url,
                        title: club.name ?? "",
                        description: club.description ?? ""
                    )
                )
                return .none
            case .receivedClub(.failure(let error)):
                print(error)
                return .none
            case let .setNavigation(selection: .some(id)):
                state.clubSelection = Identified(nil, id: id)
                guard let id = state.clubSelection?.id,
                      let new = state.clubs[id: id] else { return .none }
                state.clubSelection?.value = new
                return .none
            case .setNavigation(selection: .none):
                state.clubSelection = nil
                return .none
            case .clubAction:
                return .none
            }
        }
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
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack {
                    DetailsMapView(
                        lat: viewStore.department.latitude,
                        lon: viewStore.department.longitude
                    )
                    .frame(height: Constants.backgroundImageHeith)
                    
                    LogoView(
                        url: viewStore.department.logo?.url,
                        color: viewStore.department.color,
                        backgroundSize: Constants.logoBackgroundSize,
                        logoSize: Constants.logoSize
                    )
                    .offset(y: -(Constants.logoBackgroundSize/2))
                    .padding(.bottom, -(Constants.logoBackgroundSize/2))
                    
                    if let departmentName = viewStore.department.name {
                        Text(departmentName)
                            .font(.appMediumTitle2)
                            .horizontalPadding(.big)
                    }
                    
                    if let departmentAdress = viewStore.department.adress {
                        Text(departmentAdress)
                            .font(.appRegularTitle4)
                            .horizontalPadding(.huge)
                            .multilineTextAlignment(.center)
                    }
                    
                    ForEach(viewStore.department.infoSection) { section in
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
                            ForEach(viewStore.department.fieldOfStudy) { department in
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
                                    NavigationLink(
                                        destination: IfLetStore(
                                            self.store.scope(
                                                state: \.clubSelection?.value,
                                                action: DepartmentDetailsAction.clubAction
                                            ),
                                            then: ClubDetailsView.init(store:),
                                            else: ProgressView.init
                                        ),
                                        tag: club.id,
                                        selection: viewStore.binding(
                                            get: \.clubSelection?.id,
                                            send: DepartmentDetailsAction.setNavigation(selection:)
                                        )
                                    ) {
                                        Circle()
                                            .frame(width: 50)
                                    }
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
