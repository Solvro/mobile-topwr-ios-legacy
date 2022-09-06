import Foundation
import SwiftUI
import Common
import ComposableArchitecture
import Combine

//MARK: - STATE
public struct InfoDetailsState: Equatable, Identifiable {
    public let id: UUID
    let info: Info
    
    public init(
        id: UUID = UUID(),
        info: Info
    ){
        self.id = id
        self.info = info
    }
}
//MARK: - ACTION
public enum InfoDetailsAction: Equatable {
    case onAppear
}

//MARK: - ENVIRONMENT
public struct InfoDetailsEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let infoDetailsReducer = Reducer<
    InfoDetailsState,
    InfoDetailsAction,
    InfoDetailsEnvironment
> { state, action, env in
    switch action {
    case .onAppear:
        return .none
    }
}
//MARK: - VIEW
public struct InfoDetailsView: View {
    
    private enum Constants {
        static let backgroundImageHeigth: CGFloat = 254
        static let dateWidth: CGFloat = 100
        static let dateHeight: CGFloat = 30
    }
    
    let store: Store<InfoDetailsState, InfoDetailsAction>
    
    public init(
        store: Store<InfoDetailsState, InfoDetailsAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView(showsIndicators: false) {
                VStack{
                    ImageView(
                        url:  viewStore.info.photo?.url,
                        contentMode: .aspectFill
                    )
						.frame(height: Constants.backgroundImageHeigth)
                    HStack{
                        Text(viewStore.info.title)
                            .font(.appMediumTitle3)
                            .foregroundColor(.black)
                            .horizontalPadding(.big)
                            .padding(.bottom, UIDimensions.small.size)
                        Spacer()
                    }
                    
                    Text(viewStore.info.description ?? "")
                        .font(.appRegularTitle3)
                        .foregroundColor(.black)
                        .horizontalPadding(.big)
                    
                    ForEach(viewStore.info.infoSection) { section in
                        VStack(spacing: UIDimensions.normal.spacing) {
                            InfoSectionView(section: section)
                        }
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
