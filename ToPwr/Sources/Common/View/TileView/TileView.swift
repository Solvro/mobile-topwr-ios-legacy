import ComposableArchitecture
import SwiftUI

// FIXME: - This file is not used anywhere. Should we remove it?

public struct TileFeature: Reducer {
    public struct State: Equatable {
        public let id: Int
        let imageURL: URL?
        let title: String
        let description: String
        
        public init(
            id: Int,
            imageURL: URL?,
            title: String,
            description: String
        ){
            self.id = id
            self.imageURL = imageURL
            self.title = title
            self.description = description
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case buttonTapped
    }
    
    public var body: some ReducerOf<TileFeature> {
        EmptyReducer()
    }
}

// MARK: - View
public struct TileView: View {
    private enum Constants {
        static let viewHeight: CGFloat = 365
        static let viewWidth: CGFloat = 275
        static let banerHeight: CGFloat = 135
        static let buttonHeight: CGFloat = 32
    }

    let store: StoreOf<TileFeature>

    public init(store: StoreOf<TileFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                VStack {
                    ImageView(
                        url: viewStore.imageURL,
                        contentMode: .aspectFill
                    )
                        .cornerRadius(
                            UIDimensions.normal.cornerRadius - 3,
                            corners: [.topLeft, .topRight]
                        )
                        .frame(height: Constants.banerHeight)
                }
                .padding(1)
                VStack(alignment: .leading) {
                    HStack {
                        Text(viewStore.title)
                            .font(.appMediumTitle3)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    
                    Text(viewStore.description)
                        .font(.appRegularTitle4)
                        .verticalPadding(.normal)
                    
                    HStack {   
                        HStack {
                            Text(Strings.Other.readMore)
                                .font(.appMediumTitle4)
                                .foregroundColor(K.Colors.white)
                        }
                        .horizontalPadding(.normal)
                        .frame(height: Constants.buttonHeight)
                        .background(K.Colors.red)
                        .cornerRadius(UIDimensions.normal.cornerRadius)
                        
                        Spacer()
                    }
                }
                .padding(.normal)
            }
            .frame(
                width: Constants.viewWidth,
                height: Constants.viewHeight
            )
            .background(K.Colors.lightGray)
            .cornerRadius(UIDimensions.normal.cornerRadius)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

// TODO: - Write preview
// TODO: - Write mock
