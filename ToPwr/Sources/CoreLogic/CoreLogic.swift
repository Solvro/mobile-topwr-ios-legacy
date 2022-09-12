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
    private let fetchLimit = 10
    
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
    
    public func getDepartments(startingFrom start: Int) -> AnyPublisher<[Department], ErrorModel> {
        let path: String = "/departments"
        return api.fetch(path: path, start: start, limit: fetchLimit)
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
    
    public func getScienceClubs(startingFrom start: Int) -> AnyPublisher<[ScienceClub], ErrorModel> {
        let path: String = "/scientific-Circles"
        return api.fetch(path: path, start: start, limit: fetchLimit)
            .decode(type: [ScienceClub].self, decoder: decoder)
            .mapError { error in
                ErrorModel(text: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
	
	public func getAllScienceClubs() -> AnyPublisher<[ScienceClub], ErrorModel> {
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
    
    public func getDepartment(id: Int) -> AnyPublisher<Department, ErrorModel> {
        let path: String = "/departments/\(id)"
        return api.fetch(path: path)
            .decode(type: Department.self, decoder: decoder)
            .mapError { error in
                ErrorModel(text: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    public func getScienceClub(id: Int) -> AnyPublisher<ScienceClub, ErrorModel> {
        let path: String = "/scientific-Circles/\(id)"
        return api.fetch(path: path)
            .decode(type: ScienceClub.self, decoder: decoder)
            .mapError { error in
                ErrorModel(text: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    public func getApiVersion() -> AnyPublisher<Version, ErrorModel> {
        let path: String = "/version"
        return api.fetch(path: path)
            .decode(type: Version.self, decoder: decoder)
            .mapError { error in
                ErrorModel(text: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    public func getWhatsNew() -> AnyPublisher<[WhatsNew], ErrorModel> {
        let path: String = "/notices"
        return api.fetch(path: path)
            .decode(type: [WhatsNew].self, decoder: decoder)
            .mapError { error in
                ErrorModel(text: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    public func getInfos(startingFrom start: Int) -> AnyPublisher<[Info], ErrorModel> {
        let path: String = "/infos"
        return api.fetch(path: path, start: start, limit: fetchLimit)
            .decode(type: [Info].self, decoder: decoder)
            .mapError { error in
                ErrorModel(text: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}
