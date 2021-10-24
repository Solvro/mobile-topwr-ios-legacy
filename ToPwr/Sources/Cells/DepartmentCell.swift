//
//  File.swift
//  
//
//  Created by Jan Krzempek on 24/10/2021.
//
import SwiftUI
import ComposableArchitecture

//MARK: - STATE
public struct DepartmentCellState: Equatable {
    var text: String = "Hello World ToPwr"
    public init(){}
}
//MARK: - ACTION
public enum DepartmentCellAction: Equatable {
    case buttonTapped
}

//MARK: - ENVIRONMENT
public struct DepartmentCellEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let departmentCellReducer = Reducer<
    DepartmentCellState,
    DepartmentCellAction,
    DepartmentCellEnvironment
> { state, action, environment in
  switch action {
  case .buttonTapped:
      print("CELL TAPPED")
    return .none
  }
}

//MARK: - VIEW
public struct DepartmentCellView: View {
    let store: Store<DepartmentCellState, DepartmentCellAction>
    let imageURL: String
    let name: String
    let fullName: String
    
    public init(
        imageURL: String,
        name: String,
        fullName: String,
        store: Store<DepartmentCellState, DepartmentCellAction>
    ) {
        self.store = store
        self.imageURL = imageURL
        self.name = name
        self.fullName = fullName
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            Button(action: {
                print("DEPARTEMENT CELL TAPPED")
            }, label: {
                ZStack(alignment: .bottomLeading) {
                #warning("Replace with an ImageURL")
                    Image("tree")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 183, height: 162)
                        .cornerRadius(8)
                    VStack(alignment: .leading) {
                        Text(name)
                            .bold()
                            .padding(.bottom, 10)
                        Text(fullName)
                    }
                    .foregroundColor(.white)
                    .padding()
                }
            })
        }
    }
}

//MARK: - MOCKS & PREVIEW
#if DEBUG
struct DepartmentCell_Previews: PreviewProvider {
    static var previews: some View {
        DepartmentCellView(imageURL: "ImageURL",
                           name: "Name",
                           fullName: "FullName",
                           store: Store(initialState: .init(),
                                        reducer: departmentCellReducer,
                                        environment: .init(mainQueue: .immediate)))
    }
}
#endif
