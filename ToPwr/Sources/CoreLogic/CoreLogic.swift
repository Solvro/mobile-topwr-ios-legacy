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
    
}
