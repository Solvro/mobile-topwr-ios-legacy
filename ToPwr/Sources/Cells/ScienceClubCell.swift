//
//  File.swift
//  
//
//  Created by Jan Krzempek on 24/10/2021.
//
import SwiftUI
import ComposableArchitecture
import Common

//MARK: - STATE
public struct ScienceClubCellState: Equatable {
    var text: String = "Hello World ToPwr"
    public init(){}
}
//MARK: - ACTION
public enum ScienceClubCellAction: Equatable {
    case buttonTapped
}

//MARK: - ENVIRONMENT
public struct ScienceClubCellEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }
}

//MARK: - REDUCER
public let scienceClubCellReducer = Reducer<
    ScienceClubCellState,
    ScienceClubCellAction,
    ScienceClubCellEnvironment
> { state, action, environment in
    switch action {
    case .buttonTapped:
        print("CELL TAPPED")
        return .none
    }
}

//MARK: - VIEW
public struct ScienceClubCellView: View {
    let store: Store<ScienceClubCellState, ScienceClubCellAction>
    let imageURL: String
    let fullName: String
    
    public init(
        imageURL: String,
        fullName: String,
        store: Store<ScienceClubCellState, ScienceClubCellAction>
    ) {
        self.store = store
        self.imageURL = imageURL
        self.fullName = fullName
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            Button(action: {
                print("SCIENCE CLUB CELL TAPPED")
            }, label: {
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .foregroundColor(K.Colors.scienceBackground)
                        .cornerRadius(8)
                    VStack() {
                        HStack() {
                            Spacer()
                            ZStack() {
                                #warning("Replace with an ImageURL")
                                Rectangle()
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                                Image("tree")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 20, height: 20)
                            }
                        }
                        Spacer()
                        HStack() {
                            Text(fullName)
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }.padding()
                }
                .frame(width: 183, height: 152)
            })
        }
    }
}

//MARK: - MOCKS & PREVIEW
#if DEBUG
struct ScienceClubCell_Previews: PreviewProvider {
    static var previews: some View {
        ScienceClubCellView(imageURL: "ImageURL",
                            fullName: "Name",
                            store: Store(initialState: .init(),
                                         reducer: scienceClubCellReducer,
                                         environment: .init(mainQueue: .immediate)))
    }
}
#endif
