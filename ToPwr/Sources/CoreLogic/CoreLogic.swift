import Foundation
import Combine
import Common
import Storage
import Api

public struct CoreLogic {
    let api = Api()
    let storage = Storage()
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    public init(
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.encoder = encoder
        self.decoder = decoder
    }
    
//MARK: - API
    public func getSessionDate() -> AnyPublisher<SessionDay, ErrorModel> {
        let path: String = "/academic-year-end-date"
        return api.fetch(path: path)
            .decode(type: SessionDay.self, decoder: decoder)
            .mapError { error in
                ErrorModel(text: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    public func getDepartments() -> AnyPublisher<[Department], ErrorModel> {
        let path: String = "/departments"
        return api.fetch(path: path)
            .decode(type: [Department].self, decoder: decoder)
            .mapError { error in
                ErrorModel(text: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    public func getBuildings() -> AnyPublisher<[Map], ErrorModel> {
        let path: String = "/maps"
        return api.fetch(path: path)
            .decode(type: [Map].self, decoder: decoder)
            .mapError { error in
                ErrorModel(text: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    public func getScienceClubs() -> AnyPublisher<[ScienceClub], ErrorModel> {
        let path: String = "/scientific-Circles"
        return api.fetch(path: path)
            .decode(type: [ScienceClub].self, decoder: decoder)
            .mapError { error in
                ErrorModel(text: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    public func getWelcomeDayText() -> AnyPublisher<ExceptationDays, ErrorModel> {
        let path: String = "/week-day-exceptions"
        return api.fetch(path: path)
            .decode(type: ExceptationDays.self, decoder: decoder)
            .mapError { error in
                ErrorModel(text: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

//MARK: - Transform
    public func transform(exceptationDays: ExceptationDays) -> String {
        let currentDate = Date()
        return "test"
    }
}
