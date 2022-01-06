import ComposableArchitecture
import SwiftUI
import Common

// MARK: - State
public struct DepartmentDetailsState: Equatable, Identifiable {
    public let id: UUID
    let department: Department
    
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
    case onDisappear
}

// MARK: - Environment
public struct DepartmentDetailsEnvironment {
    public init() {}
}

// MARK: - Reducer
public let departmentDetailsReducer = Reducer<
    DepartmentDetailsState,
    DepartmentDetailsAction,
    DepartmentDetailsEnvironment
> { _, action, _ in
    switch action {
    case .onAppear:
        return .none
    case .onDisappear:
        return .none
    }
}

// MARK: - View
public struct DepartmentDetailsView: View {

    private enum Constants {
        static let backgroundImageHeith: CGFloat = 254
        static let avatarSize: CGFloat = 120
    }


    let store: Store<DepartmentDetailsState, DepartmentDetailsAction>

    public init(store: Store<DepartmentDetailsState, DepartmentDetailsAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack {
                    DepartmentMapView()
                        .frame(height: Constants.backgroundImageHeith)
                    
                    ImageView(
                        url: URL(string: viewStore.department.photo?.url ?? ""),
                        contentMode: .aspectFill
                    )
                        .frame(
                            width: Constants.avatarSize,
                            height: Constants.avatarSize
                        )
                        .clipShape(Circle())
                        .shadow(radius: 7, x: 0, y: -5)
                        .offset(y: -(Constants.avatarSize/2))
                        .padding(.bottom, -(Constants.avatarSize/2))
                    
                    Text(viewStore.department.name ?? "")
                        .font(.appBoldTitle2)
                        .horizontalPadding(.big)
                    
                    Text("TODO: Adres")
                        .font(.appRegularTitle2)
                        .horizontalPadding(.huge)
                    
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            
        }
    }
}
