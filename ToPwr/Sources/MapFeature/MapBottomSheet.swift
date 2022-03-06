import SwiftUI
import ComposableArchitecture
import Combine
import Common
import HomeFeature

//MARK: - STATE
public struct MapBottomSheetState: Equatable {
    var searchState = SearchState()
    var text: String = ""
    
    var buildings: IdentifiedArrayOf<MapBuildingCellState> = []
    var filtered: IdentifiedArrayOf<MapBuildingCellState>
    @BindableState var isOpen: Bool = false
    
    public init(
        buildings: [MapBuildingCellState] = []
    ){
        self.buildings = .init(uniqueElements: buildings)
        self.filtered = self.buildings
    }
}

//MARK: - ACTION
public enum MapBottomSheetAction: Equatable {
    case isOpenChanged(Bool)
    case searchAction(SearchAction)
    case cellAction(id: MapBuildingCellState.ID, action: MapBuildingCellAction)
}

//MARK: - ENVIRONMENT
public struct MapBottomSheetEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let mapBottomSheetReducer = Reducer<
    MapBottomSheetState,
    MapBottomSheetAction,
    MapBottomSheetEnvironment
> .combine(
    mapBuildingCellReducer.forEach(
        state: \.buildings,
        action: /MapBottomSheetAction.cellAction(id:action:),
        environment: { env in
                .init(mainQueue: env.mainQueue)
        }
    ),
    Reducer{ state, action, environment in
        switch action {
        case .cellAction:
            return .none
        case .searchAction(.update(let text)):
            state.text = text
            #warning("TODO: filter refactor")
            if text.count == 0 {
                state.filtered = state.buildings
            } else {
                state.filtered = .init(
                    uniqueElements: state.buildings.filter {
                        $0.building.name?.contains(text) ?? false ||
                        $0.building.code?.contains(text) ?? false
                    }
                )
            }
            return .none
        case .searchAction:
            return .none
        case .isOpenChanged(let value):
            state.isOpen = value
            return .none
        }
    }
)

//MARK: - VIEW
struct MapBottomSheetView: View {
    fileprivate enum Constants {
        static let radius: CGFloat = 16
        static let indicatorHeight: CGFloat = 6
        static let indicatorWidth: CGFloat = 60
        static let snapRatio: CGFloat = 0.25
        static let minHeightRatio: CGFloat = 0.3
    }
    
    @GestureState private var translation: CGFloat = 0
    @State private var isOpenInternal: Bool = false
    let store: Store<MapBottomSheetState, MapBottomSheetAction>
    
    let maxHeight: CGFloat
    let minHeight: CGFloat
    
    var indicator: some View {
        RoundedRectangle(cornerRadius: Constants.radius)
            .fill(Color.secondary)
            .frame(
                width: Constants.indicatorWidth,
                height: Constants.indicatorHeight
            )
    }
    
    public init(
        maxHeight: CGFloat,
        store: Store<MapBottomSheetState, MapBottomSheetAction>
    ) {
        self.maxHeight = maxHeight
        self.minHeight = maxHeight * Constants.minHeightRatio
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    self.indicator.padding()
                    VStack(alignment: .leading, spacing: 0) {
                        Text(Strings.MapView.buildings)
                            .bold()
                            .padding()
                        SearchView(
                            store: self.store.scope(
                                state: \.searchState,
                                action: MapBottomSheetAction.searchAction
                            )
                        ).padding(.bottom, 10)
                        ScrollView(.vertical, showsIndicators: true) {
                            LazyVStack(spacing: 10) {
                                ForEachStore(
                                    self.store.scope(
                                        state: \.filtered,
                                        action: MapBottomSheetAction.cellAction(id:action:)
                                    )
                                ) { store in
                                    MapBuildingCellView(store: store)
                                }
                            }
                            .horizontalPadding(.normal)
                        }
                    }
                }
                .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
                .background(Color.white)
                .cornerRadius(Constants.radius, corners: [.topLeft, .topRight])
                .frame(height: geometry.size.height, alignment: .bottom)
                .offset(y: max((isOpenInternal ? 0 : self.maxHeight - (self.maxHeight * Constants.minHeightRatio)) + self.translation, 0))
                .animation(.default)
                .gesture(
                    DragGesture().updating(self.$translation) { value, state, _ in
                        state = value.translation.height
                    }.onEnded { value in
                        let snapDistance = self.maxHeight * Constants.snapRatio
                        guard abs(value.translation.height) > snapDistance else {
                            return
                        }
                        value.translation.height < 0 ? (isOpenInternal = true) : (isOpenInternal = false)
                    }
                )
            }
        }
    }
}
