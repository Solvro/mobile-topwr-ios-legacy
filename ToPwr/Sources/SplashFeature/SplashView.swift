import SwiftUI
import ComposableArchitecture
import Combine
import Common
import MenuFeature
import PureSwiftUI

private typealias Curve = (p: CGPoint, cp1: CGPoint, cp2: CGPoint)
private let toPwrLayoutConfig = LayoutGuideConfig.grid(columns: 10, rows: 5)

//MARK: - STATE
public struct SplashState: Equatable {
    var isLoading: Bool = true {
        willSet {
            if !newValue {
                withAnimation {
                    showWritingAnimation = true
                }
            }
        }
    }
    var showWritingAnimation: Bool = true
    
    var menuState = MenuState()
    public init(){}
}
//MARK: - ACTION
public enum SplashAction: Equatable {
    case onAppear
    case apiVersion(Result<Version, ErrorModel>)
    case stopLoading
    case setWriting(Bool)
    case menuAction(MenuAction)
}

//MARK: - ENVIRONMENT
public struct SplashEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getApiVersion: () -> AnyPublisher<Version, ErrorModel>
    let getSessionDate: () -> AnyPublisher<SessionDay, ErrorModel>
    let getDepartments: () -> AnyPublisher<[Department], ErrorModel>
    let getBuildings: () -> AnyPublisher<[Map], ErrorModel>
    let getScienceClubs: () -> AnyPublisher<[ScienceClub], ErrorModel>
    let getWelcomeDayText: () -> AnyPublisher<ExceptationDays, ErrorModel>
    let getDepartment: (Int) -> AnyPublisher<Department, ErrorModel>
    let getScienceClub: (Int) -> AnyPublisher<ScienceClub, ErrorModel>
    let getWhatsNew: () -> AnyPublisher<[WhatsNew], ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getApiVersion: @escaping () -> AnyPublisher<Version, ErrorModel>,
        getSessionDate: @escaping () -> AnyPublisher<SessionDay, ErrorModel>,
        getDepartments: @escaping () -> AnyPublisher<[Department], ErrorModel>,
        getBuildings: @escaping () -> AnyPublisher<[Map], ErrorModel>,
        getScienceClubs: @escaping () -> AnyPublisher<[ScienceClub], ErrorModel>,
        getWelcomeDayText: @escaping () -> AnyPublisher<ExceptationDays, ErrorModel>,
        getDepartment: @escaping (Int) -> AnyPublisher<Department, ErrorModel>,
        getScienceClub: @escaping (Int) -> AnyPublisher<ScienceClub, ErrorModel>,
        getWhatsNew: @escaping () -> AnyPublisher<[WhatsNew], ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getApiVersion = getApiVersion
        self.getSessionDate = getSessionDate
        self.getDepartments = getDepartments
        self.getBuildings = getBuildings
        self.getScienceClubs = getScienceClubs
        self.getWelcomeDayText = getWelcomeDayText
        self.getDepartment = getDepartment
        self.getScienceClub = getScienceClub
        self.getWhatsNew = getWhatsNew
    }
}

//MARK: - REDUCER
public let splashReducer = Reducer<
    SplashState,
    SplashAction,
    SplashEnvironment
> { state, action, env in
    switch action {
    case .onAppear:
        return env.getApiVersion()
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map(SplashAction.apiVersion)
    case .apiVersion(.success(let version)):
        return .init(value: .stopLoading)
    case .apiVersion(.failure(let error)):
        print(error.localizedDescription)
        return .none
    case .stopLoading:
        state.isLoading = false
        return .none
    case .setWriting(let newValue):
        state.showWritingAnimation = newValue
        return .none
    case .menuAction:
        return .none
    }
}
.combined(
    with: menuReducer
        .pullback(
            state: \.menuState,
            action: /SplashAction.menuAction,
            environment: {
                .init(
                    mainQueue: $0.mainQueue,
                    getSessionDate: $0.getSessionDate,
                    getDepartments: $0.getDepartments,
                    getBuildings: $0.getBuildings,
                    getScienceClubs: $0.getScienceClubs,
                    getWelcomeDayText: $0.getWelcomeDayText,
                    getDepartment: $0.getDepartment,
                    getScienceClub: $0.getScienceClub,
                    getWhatsNew: $0.getWhatsNew
                )
            }
        )
)

//MARK: - VIEW
public struct SplashView: View {
    let store: Store<SplashState, SplashAction>
    
    @State var scale: CGFloat = 1.0
    @State private var progress = 0.0
    
    enum Constants {
        static let lineWidth: CGFloat = 11
        static let animationDuration: Double = 2
        static let checkIfLoadedAfter: Int = 3
        static let baseLetterFrame: CGSize = CGSize(width: 60, height: 60)
        static let smallLetterFrame: CGSize = CGSize(width: 20, height: 20)
        static let smallCorrectionOffset: CGFloat = -10
        static let mediumCorrectionOffset: CGFloat = -17
        static let shadowParameters: (CGFloat,CGFloat,CGFloat) = (10,10,10) // (radius,x,y)
    }
    
    var repeatingAnimation: Animation {
        Animation
            .easeInOut(duration: 1.2)
            .repeatForever()
    }
    
    public init(
        store: Store<SplashState, SplashAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                if viewStore.showWritingAnimation {
                    HStack(alignment: .bottom,spacing: 0) {
                        //MARK: - T Letter
                        ZStack {
                            TVertLine()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    K.Colors.logoBlue,
                                    style: StrokeStyle(
                                        lineWidth: Constants.lineWidth,
                                        lineCap: .round, lineJoin: .round
                                    )
                                )
                            THoriLine()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    K.Colors.logoBlue,
                                    style: StrokeStyle(
                                        lineWidth: Constants.lineWidth,
                                        lineCap: .round, lineJoin: .round
                                    )
                                )
                        }
                        .frame(Constants.baseLetterFrame)
                        
                        //MARK: - O letter
                        OLetter()
                            .trim(from: 0, to: progress)
                            .stroke(
                                K.Colors.logoBlue,
                                style: StrokeStyle(
                                    lineWidth: Constants.lineWidth,
                                    lineCap: .round, lineJoin: .round
                                )
                            )
                            .frame(Constants.smallLetterFrame)
                            .offset(x: Constants.smallCorrectionOffset)
                        
                        //MARK: - P letter
                        ZStack {
                            PRVertLine()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    K.Colors.firstColorDark,
                                    style: StrokeStyle(
                                        lineWidth: Constants.lineWidth,
                                        lineCap: .round, lineJoin: .round
                                    )
                                )
                            PRHoriShape()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    K.Colors.firstColorDark,
                                    style: StrokeStyle(
                                        lineWidth: Constants.lineWidth,
                                        lineCap: .round, lineJoin: .round
                                    )
                                )
                        }
                        .frame(Constants.baseLetterFrame)
                        
                        //MARK: - W letter
                        ZStack{
                            WSpecificLineLeft()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    K.Colors.firstColorDark,
                                    style: StrokeStyle(
                                        lineWidth: Constants.lineWidth,
                                        lineCap: .round, lineJoin: .round
                                    )
                                )
                            WSpecificLineRight()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    K.Colors.firstColorDark,
                                    style: StrokeStyle(
                                        lineWidth: Constants.lineWidth,
                                        lineCap: .round, lineJoin: .round
                                    )
                                )
                        }
                        .frame(Constants.baseLetterFrame)
                        .offset(x: Constants.smallCorrectionOffset)
                        
                        //MARK: - R letter
                        ZStack{
                            RSpecificLine()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    K.Colors.firstColorDark,
                                    style: StrokeStyle(
                                        lineWidth: Constants.lineWidth,
                                        lineCap: .round, lineJoin: .round
                                    )
                                )
                            PRVertLine()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    K.Colors.firstColorDark,
                                    style: StrokeStyle(
                                        lineWidth: Constants.lineWidth,
                                        lineCap: .round, lineJoin: .round
                                    )
                                )
                            PRHoriShape()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    K.Colors.firstColorDark,
                                    style: StrokeStyle(
                                        lineWidth: Constants.lineWidth,
                                        lineCap: .round, lineJoin: .round
                                    )
                                )
                        }
                        .frame(Constants.baseLetterFrame)
                        .offset(x: Constants.mediumCorrectionOffset)
                    }
                    .shadow(
                        color: K.Colors.lightGray,
                        radius: Constants.shadowParameters.0,
                        x: Constants.shadowParameters.1,
                        y: Constants.shadowParameters.2
                    )
                    .onAppear {
                        withAnimation(.easeInOut(duration: Constants.animationDuration)){
                            progress = 1.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(Constants.checkIfLoadedAfter)) {
                            withAnimation {
                                viewStore.send(.setWriting(false))
                            }
                        }
                    }
                    
                }else if viewStore.isLoading{
                    LoadingAnimation()
                } else {
                    MenuView(
                        store: self.store.scope(
                            state: \.menuState,
                            action: SplashAction.menuAction
                        )
                    )
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .modifier(SplashBackgroundModifier())
        }
    }
    
    private struct TVertLine: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let g = toPwrLayoutConfig.layout(in: rect)
            
            let startPoint = g[5,5]
            let p2 = g[5,1]
            
            path.move(startPoint)
            path.addLine(to: p2)
            
            return path
        }
    }
    
    private struct THoriLine: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let g = toPwrLayoutConfig.layout(in: rect)
            
            let startPoint = g[3,1]
            let p2 = g[9,1]
            
            path.move(startPoint)
            path.addLine(to: p2)
            
            return path
        }
    }
    
    private struct OLetter: Shape {
        private let oLayoutGuide = LayoutGuideConfig.polar(rings: 1, segments: 40)
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let g = oLayoutGuide.layout(in: rect)
            let startPoint = g[1,1]
            var points: [CGPoint] = []
            
            for index in 1...40 {
                points.append(g[1,index])
            }
            
            path.move(startPoint)
            
            for point in points {
                path.addLine(to: point)
            }
            
            path.addLine(to: startPoint)
            
            return path
        }
    }
    
    private struct PRVertLine: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let g = toPwrLayoutConfig.layout(in: rect)
            
            let startPoint = g[4,5]
            let p2 = g[4,1]
            
            path.move(startPoint)
            path.addLine(to: p2)
            
            return path
        }
    }
    
    private struct PRHoriShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let g = toPwrLayoutConfig.layout(in: rect)
            
            let startPoint = g[2,1]
            let p2 = g[6,1]
            let p3 = g[6,3]
            let p4 = g[3,3]
            
            path.move(startPoint)
            path.addLine(to: p2)
            path.curve(p3, cp1: g[8,1], cp2: g[8,3])
            path.addLine(to: p4)
            
            return path
        }
    }
    
    private struct RSpecificLine: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let g = toPwrLayoutConfig.layout(in: rect)
            
            let startPoint = g[7,5]
            let p2 = g[7,4]
            let p3 = g[6,3]
            let p4 = g[3,3]
            
            path.move(startPoint)
            path.addLine(to: p2)
            path.curve(p3, cp1: g[7,3], cp2: g[7,3])
            path.addLine(to: p4)
            
            return path
        }
    }
    
    private struct WSpecificLineLeft: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let g = toPwrLayoutConfig.layout(in: rect)
            
            let startPoint = g[2,1]
            let p2 = g[2,4]
            let p3 = g[5,4]
            let p4 = g[5,2]
            
            path.move(startPoint)
            path.addLine(to: p2)
            path.curve(p3, cp1: g[2,5], cp2: g[5,5])
            path.addLine(to: p4)
            
            return path
        }
    }
    
    private struct WSpecificLineRight: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let g = toPwrLayoutConfig.layout(in: rect)
            
            let startPoint = g[8,1]
            let p2 = g[8,4]
            let p3 = g[5,4]
            let p4 = g[5,2]
            
            path.move(startPoint)
            path.addLine(to: p2)
            path.curve(p3, cp1: g[8,5], cp2: g[5,5])
            path.addLine(to: p4)
            
            return path
        }
    }
}

#if DEBUG
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(
            store: Store(
                initialState: .init(),
                reducer: splashReducer,
                environment: .init(
                    mainQueue: .immediate,
                    getApiVersion: failing0,
                    getSessionDate: failing0,
                    getDepartments: failing0,
                    getBuildings: failing0,
                    getScienceClubs: failing0,
                    getWelcomeDayText: failing0,
                    getDepartment: failing1,
                    getScienceClub: failing1,
                    getWhatsNew: failing0
                )
            )
        )
    }
}
#endif
