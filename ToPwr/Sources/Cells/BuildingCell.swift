//
//  File.swift
//  
//
//  Created by Jan Krzempek on 24/10/2021.
//
import SwiftUI
import ComposableArchitecture

//MARK: - STATE
public struct BuildingCellState: Equatable {
    var text: String = "Hello World ToPwr"
    public init(){}
}
//MARK: - ACTION
public enum BuildingCellAction: Equatable {
    case buttonTapped
}

//MARK: - ENVIRONMENT
public struct BuildingCellEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let buildingCellReducer = Reducer<
    BuildingCellState,
    BuildingCellAction,
    BuildingCellEnvironment
> { state, action, environment in
  switch action {
  case .buttonTapped:
    return .none
  }
}

//MARK: - VIEW
public struct BuildingCellView: View {
    let store: Store<BuildingCellState, BuildingCellAction>
    let imageURL: String
    let name: String
    
    public init(
        imageURL: String,
        name: String,
        store: Store<BuildingCellState, BuildingCellAction>
    ) {
        self.store = store
        self.imageURL = imageURL
        self.name = name
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            Button(action: {
                print("BUILDING CELL TAPPED")
            }, label: {
                #warning("Replace with an ImageURL")
                ZStack(alignment: .bottomLeading) {
                    Image("tree")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .cornerRadius(8)
                    Text(name)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                }
            })
        }
    }
}

//MARK: - MOCKS & PREVIEW
#if DEBUG
struct BuildingCell_Previews: PreviewProvider {
    static var previews: some View {
        BuildingCellView(imageURL: "Image",
                         name: "Name",
                         store: Store(initialState: .init(),
                                      reducer: buildingCellReducer,
                                      environment: .init(mainQueue: .immediate)))
    }
}
#endif
