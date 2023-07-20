import SwiftUI
import ComposableArchitecture
import Combine
import Common
import HomeFeature

public struct MapBottomSheet: ReducerProtocol {
    //MARK: - State
    public struct State: Equatable {
        let navigateButtonTitle: String = Strings.MapView.navigateMe
        var searchState = SearchFeature.State(placeholder: Strings.Other.searching)
        var text: String = ""
        
        var buildings: IdentifiedArrayOf<MapBuildingCell.State> = []
        var filtered: IdentifiedArrayOf<MapBuildingCell.State>
        var selectedId: MapBuildingCell.State?
        
        public init(
            buildings: [MapBuildingCell.State] = [],
            selectedId: MapBuildingCell.State? = nil
        ){
            self.buildings = .init(uniqueElements: buildings)
            self.filtered = self.buildings
            self.selectedId = selectedId
        }
    }
    
    //MARK: - Action
    public enum Action: Equatable {
        case searchAction(SearchFeature.Action)
        case cellAction(id: MapBuildingCell.State.ID, action: MapBuildingCell.Action)
        case configureToSelectedAnnotationAcion(CustomAnnotation?)
        case newCellSelected(Int?)
        case selectedCellAction(MapBuildingCell.Action)
        case forcedCellAction(id: MapBuildingCell.State.ID, action: MapBuildingCell.Action) //enables imposing influance on the "selected cell" state without consequences from outside reducers
        case remoteCancelationConf
    }
    
    //MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .cellAction(id: let id, action: .buttonTapped):
                return .init(value: .newCellSelected(id))
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
                if let safeSelection = state.selectedId {
                    state.filtered.remove(safeSelection)
                }
                return .none
            case .searchAction(.clearSearch):
                state.text = ""
                return .none
            case .configureToSelectedAnnotationAcion(let annotation):
                return .none
            case .newCellSelected(let id):
                if let safeNewState = state.filtered.first(where: { $0.id == id}) {
                    var oldSelection = state.selectedId
                    oldSelection?.isSelected = false // changing property to fit the unselected cells design
                    state.selectedId = safeNewState
                    state.selectedId?.isSelected = true
                    state.filtered.remove(safeNewState)
                    if let oldSelection = oldSelection {
                        state.filtered.append(oldSelection)
                    }
                }
                return .init(value: .remoteCancelationConf) // whenever new cell is selected sheet has to go down
            case .selectedCellAction(.buttonTapped):
                state.selectedId = nil
                state.filtered = state.buildings
                state.filtered.sort(by: { $0.building.code ?? "" < $1.building.code ?? ""})
                return .none
            case .forcedCellAction(id: let id, action: let action):
                return .init(value: .newCellSelected(id))
            case .remoteCancelationConf:
                // this effect ensures correct order of state modifications so that
                // bottom sheet will close when selecting cell and open when sheet is closed
                // and seleced cell is pressed
                return .none
            }
        }
    }
}

//MARK: - VIEW
struct MapBottomSheetView: View {
	fileprivate enum Constants {
		static let radius: CGFloat = 16
		static let indicatorHeight: CGFloat = 6
		static let indicatorWidth: CGFloat = 60
		static let snapRatio: CGFloat = 0.25
		static let minHeightRatio: CGFloat = 0.3
        static let navigateIcon: String = "paperplane.fill"
	}
    
    let store: StoreOf<MapBottomSheet>
	var isOpenInternal: Binding<Bool>
	var isFullViewInternal: Binding<Bool>
	
	let maxHeight: CGFloat
	let minHeight: CGFloat
	let offset = { maxHeight in maxHeight - (maxHeight * Constants.minHeightRatio) }
	@State var topHeight: CGFloat!
    @GestureState private var translation: CGFloat = 0
	
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
		store: StoreOf<MapBottomSheet>,
		isOpen: Binding<Bool>,
		isFullView: Binding<Bool>
	) {
		self.maxHeight = maxHeight
		self.minHeight = maxHeight * Constants.minHeightRatio
		self.store = store
		self.isOpenInternal = isOpen
		self.isFullViewInternal = isFullView
		self.topHeight = nil
	}
	
	public var body: some View {
		WithViewStore(store) { viewStore in
			GeometryReader { geometry in
				VStack(spacing: 1) {
					GeometryReader { proxy in
						VStack(alignment: .leading, spacing: 0) {
							HStack {
								Spacer()
								self.indicator.padding()
								Spacer()
							}
                            HStack {
                                Text(Strings.MapView.buildings)
                                    .font(.appMediumTitle2)
                                    .padding()
                                Spacer()
                                if let selected = viewStore.selectedId {
                                    Button(
                                        action: {
                                            let lat: String = String(format: "%.3f", selected.building.latitude ?? "0")
                                            let lon: String = String(format: "%.3f", selected.building.longitude ?? "0")
                                            guard
                                                let url = URL(
                                                    string: "maps://?saddr=&daddr=\(lat),\(lon)"
                                                ),
                                                UIApplication.shared.canOpenURL(url)
                                            else {
                                                print("Could't load map")
                                                return
                                            }
                                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                        },
                                        label: {
                                            HStack {
                                                Text(viewStore.navigateButtonTitle)
                                                    .font(.appBoldTitle4)
                                                Image(systemName: Constants.navigateIcon)
                                                    .foregroundColor(K.Colors.red)
                                            }
                                        }
                                    )
                                    .padding()
                                }
                            }
							SearchView(
								store: store.scope(
									state: \.searchState,
                                    action: MapBottomSheet.Action.searchAction
								)
							).padding(.bottom, 10)
						}
						.onAppear {
							self.topHeight = proxy.size.height + 95 // 95 is the one cell height 90 + 5 points of padding
						}
					}
					
					ScrollView(.vertical, showsIndicators: true) {
						LazyVStack(spacing: 10) {
							// optional selected cell
							IfLetStore(
								store.scope(
									state: \.selectedId,
                                    action: MapBottomSheet.Action.selectedCellAction
								),
								then: MapBuildingCellView.init(store:),
								else: { EmptyView() }
							)
							// available cells
							ForEachStore(
								store.scope(
									state: \.filtered,
                                    action: MapBottomSheet.Action.cellAction(id:action:)
								)
							) { store in
								MapBuildingCellView(
									store: store
								)
							}
						}
						.horizontalPadding(.normal)
					}
					.frame(minHeight: self.maxHeight * 0.75)
                    .id(viewStore.state.selectedId?.id)
				}
				.frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
				.background(Color.white)
				.cornerRadius(Constants.radius, corners: [.topLeft, .topRight])
				.frame(height: geometry.size.height, alignment: .bottom)
				.offset(y: max((isOpenInternal.wrappedValue ? isFullViewInternal.wrappedValue ? 0 : maxHeight - topHeight : self.offset(maxHeight)) + self.translation, 0))
				.gesture(
					DragGesture().updating(self.$translation) { value, state, _ in
						state = value.translation.height
					}.onEnded { value in
						let snapDistance = self.maxHeight * Constants.snapRatio
						let smallSnapDistance = self.topHeight * Constants.snapRatio
						print(isFullViewInternal.wrappedValue)
						if self.isFullViewInternal.wrappedValue {
							guard abs(value.translation.height) > snapDistance else {
								// this makes sure certain distance was exceded
								return
							}
						}	else {
							guard abs(value.translation.height) > smallSnapDistance else {
								// this makes sure certain distance was exceded
								return
							}
						}
						
						value.translation.height < 0 ? (isOpenInternal.wrappedValue = true) : (isOpenInternal.wrappedValue = false)
						// this tells app in what direction was the sheet pulled
						
						isFullViewInternal.wrappedValue = true
						// no matter the direction app resets isFullViewInternal to default value
					}
				)
			}
		}
	}
}
