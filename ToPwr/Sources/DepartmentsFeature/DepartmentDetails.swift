import ComposableArchitecture
import Combine
import SwiftUI
import Common
import IdentifiedCollections

// MARK: - State
public struct DepartmentDetailsState: Equatable, Identifiable {
    public let id: UUID
    let department: Department
    var items: IdentifiedArrayOf<TileState> = []
    var clubs: [ScienceClub] = []
    
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
    case clubAction(id: TileState.ID, action: TileAction)
}

// MARK: - Environment
public struct DepartmentDetailsEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getScienceClub: (Int) -> AnyPublisher<ScienceClub, ErrorModel>
    
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getScienceClub: @escaping (Int) -> AnyPublisher<ScienceClub, ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getScienceClub = getScienceClub
    }
}

// MARK: - Reducer
public let departmentDetailsReducer = Reducer<
    DepartmentDetailsState,
    DepartmentDetailsAction,
    DepartmentDetailsEnvironment
>
    .combine(
        tileReducer.forEach(
            state: \.items,
            action: /DepartmentDetailsAction.clubAction(id:action:),
            environment: { _ in .init() }
        ),
        Reducer{ state, action, env in
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
                print("LOAD SCIENCE CLUB: \(id)")
                return env.getScienceClub(id)
                    .receive(on: env.mainQueue)
                    .catchToEffect()
                    .map(DepartmentDetailsAction.receivedClub)
            case .receivedClub(.success(let club)):
                state.clubs.append(club)
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
                    
                    Text(viewStore.department.name ?? "")
                        .font(.appBoldTitle2)
                        .horizontalPadding(.big)
                    
                    Text("TODO: Adres")
                        .font(.appRegularTitle2)
                        .horizontalPadding(.huge)
                    
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
                                .font(.appBoldTitle2)
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
                                .font(.appBoldTitle2)
                            Spacer()
                        }
                        .padding(.normal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEachStore(
                                    self.store.scope(
                                        state: \.items,
                                        action: DepartmentDetailsAction.clubAction(id:action:)
                                    )
                                ) { store in
                                    TileView(store: store)
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
                    .font(.appBoldTitle2)
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
        getScienceClub: failing1
    )
}
#endif
