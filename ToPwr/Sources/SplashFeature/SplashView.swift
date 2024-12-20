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
	var isLoading: Bool = true
	var showWritingAnimation: Bool = true
	var listinerTime = 3 // 3 because before we start counting we do the animation that takes 3 seconds
	var showAlert = false
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
	case delayWritingBy(Int)
	case startMonitoring
	case checkIfFinished
	case showAlertChange(Bool)
}

//MARK: - ENVIRONMENT
public struct SplashEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let getApiVersion: () -> AnyPublisher<Version, ErrorModel>
    let getSessionDate: () -> AnyPublisher<SessionDay, ErrorModel>
    let getDepartments: (Int) -> AnyPublisher<[Department], ErrorModel>
    let getBuildings: () -> AnyPublisher<[Map], ErrorModel>
    let getScienceClubs: (Int) -> AnyPublisher<[ScienceClub], ErrorModel>
	let getAllScienceClubs: () -> AnyPublisher<[ScienceClub], ErrorModel>
    let getWelcomeDayText: () -> AnyPublisher<ExceptationDays, ErrorModel>
    let getDepartment: (Int) -> AnyPublisher<Department, ErrorModel>
    let getScienceClub: (Int) -> AnyPublisher<ScienceClub, ErrorModel>
    let getWhatsNew: () -> AnyPublisher<[WhatsNew], ErrorModel>
    let getInfos: (Int) -> AnyPublisher<[Info], ErrorModel>
	let getAboutUs: () -> AnyPublisher<AboutUs, ErrorModel>
    
    public init (
        mainQueue: AnySchedulerOf<DispatchQueue>,
        getApiVersion: @escaping () -> AnyPublisher<Version, ErrorModel>,
        getSessionDate: @escaping () -> AnyPublisher<SessionDay, ErrorModel>,
        getDepartments: @escaping (Int) -> AnyPublisher<[Department], ErrorModel>,
        getBuildings: @escaping () -> AnyPublisher<[Map], ErrorModel>,
        getScienceClubs: @escaping (Int) -> AnyPublisher<[ScienceClub], ErrorModel>,
		getAllScienceClubs: @escaping () -> AnyPublisher<[ScienceClub], ErrorModel>,
        getWelcomeDayText: @escaping () -> AnyPublisher<ExceptationDays, ErrorModel>,
        getDepartment: @escaping (Int) -> AnyPublisher<Department, ErrorModel>,
        getScienceClub: @escaping (Int) -> AnyPublisher<ScienceClub, ErrorModel>,
        getWhatsNew: @escaping () -> AnyPublisher<[WhatsNew], ErrorModel>,
        getInfos: @escaping (Int) -> AnyPublisher<[Info], ErrorModel>,
		getAboutUs: @escaping () -> AnyPublisher<AboutUs, ErrorModel>
    ) {
        self.mainQueue = mainQueue
        self.getApiVersion = getApiVersion
        self.getSessionDate = getSessionDate
        self.getDepartments = getDepartments
        self.getBuildings = getBuildings
        self.getScienceClubs = getScienceClubs
		self.getAllScienceClubs = getAllScienceClubs
        self.getWelcomeDayText = getWelcomeDayText
        self.getDepartment = getDepartment
        self.getScienceClub = getScienceClub
        self.getWhatsNew = getWhatsNew
        self.getInfos = getInfos
		self.getAboutUs = getAboutUs
    }
}

//MARK: - REDUCER
public let splashReducer = Reducer<
	SplashState,
	SplashAction,
	SplashEnvironment
> { state, action, env in
	enum ListinerID {}
	
	switch action {
	case .onAppear:
		return env.getApiVersion()
			.receive(on: env.mainQueue)
			.catchToEffect()
			.map(SplashAction.apiVersion)
	case .apiVersion(.success(let version)):
		return .init(value: .stopLoading)
	case .apiVersion(.failure(let error)):
		return .none
	case .stopLoading:
		state.isLoading = false
		return .none
	case .setWriting(let newValue):
		state.showWritingAnimation = newValue
		return .none
	case .menuAction:
		return .none
	case .delayWritingBy(let delay):
		return .task {
			try await env.mainQueue.sleep(for: .seconds(delay))
			return .startMonitoring
		}
	case .startMonitoring:
		return .run { send in
			do {
				while true {
					try await env.mainQueue.sleep(for: .seconds(0.5))
					await send(.checkIfFinished)
				}
			}	catch{}
		}
		.cancellable(id: ListinerID.self)
	case .checkIfFinished:
		state.listinerTime += 1
		
		if state.listinerTime == 30 {
			state.showAlert = true
			return .cancel(id: ListinerID.self)
		}
		
		if state.isLoading {
			return .none
		}	else {
			return .concatenate (
				.init(value: .setWriting(false)),
				.cancel(id: ListinerID.self)
			)
		}
	case .showAlertChange(let newVal):
		state.showAlert = newVal
		if !newVal {
			state.listinerTime = 0
			return	.concatenate (
				.init(value: .onAppear),
				.init(value: .startMonitoring)
			)
		}
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
						getAllScienceClubs: $0.getAllScienceClubs,
                        getWelcomeDayText: $0.getWelcomeDayText,
                        getDepartment: $0.getDepartment,
                        getScienceClub: $0.getScienceClub,
                        getWhatsNew: $0.getWhatsNew,
                        getInfos: $0.getInfos,
						getAboutUs: $0.getAboutUs
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
									.white,
									style: StrokeStyle(
										lineWidth: Constants.lineWidth,
										lineCap: .round, lineJoin: .round
									)
								)
							THoriLine()
								.trim(from: 0, to: progress)
								.stroke(
									.white,
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
								.white,
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
									.white,
									style: StrokeStyle(
										lineWidth: Constants.lineWidth,
										lineCap: .round, lineJoin: .round
									)
								)
							PRHoriShape()
								.trim(from: 0, to: progress)
								.stroke(
									.white,
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
									.white,
									style: StrokeStyle(
										lineWidth: Constants.lineWidth,
										lineCap: .round, lineJoin: .round
									)
								)
							WSpecificLineRight()
								.trim(from: 0, to: progress)
								.stroke(
									.white,
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
									.white,
									style: StrokeStyle(
										lineWidth: Constants.lineWidth,
										lineCap: .round, lineJoin: .round
									)
								)
							PRVertLine()
								.trim(from: 0, to: progress)
								.stroke(
									.white,
									style: StrokeStyle(
										lineWidth: Constants.lineWidth,
										lineCap: .round, lineJoin: .round
									)
								)
							PRHoriShape()
								.trim(from: 0, to: progress)
								.stroke(
									.white,
									style: StrokeStyle(
										lineWidth: Constants.lineWidth,
										lineCap: .round, lineJoin: .round
									)
								)
						}
						.frame(Constants.baseLetterFrame)
						.offset(x: Constants.mediumCorrectionOffset)
					}
					.onAppear {
						withAnimation(.easeInOut(duration: Constants.animationDuration)){
							progress = 1.0
						}
						viewStore.send(.delayWritingBy(Constants.checkIfLoadedAfter))
					}
					.alert(isPresented: Binding(
						get: { viewStore.showAlert },
						set: { viewStore.send(.showAlertChange($0)) }
					)){
						Alert(
							title: Text("Problem z internetem"),
							dismissButton: .default(Text("Spróbuj ponownie"))
						)
					}
				}else {
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
                    getDepartments: failing1,
                    getBuildings: failing0,
					getScienceClubs: failing1,
					getAllScienceClubs: failing0,
                    getWelcomeDayText: failing0,
                    getDepartment: failing1,
                    getScienceClub: failing1,
                    getWhatsNew: failing0,
                    getInfos: failing1,
					getAboutUs: failing0
                )
            )
        )
    }
}
#endif
