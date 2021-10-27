import Foundation
import Combine
import ComposableArchitecture
import Common

public struct Api {
    private let scheme = "https://"
    private let host = "to-pwr-backend.herokuapp.com"
    private let session: URLSession
    
    public init() {
        self.session = URLSession.shared
    }
    
    public func fetch(path: String) -> AnyPublisher<Data, ErrorModel> {
        guard let url: URL = .init(
            string: scheme + host + path
        )
        else {
            return Fail(error: ErrorModel(text: "Couldn't generate url"))
                .eraseToAnyPublisher()
        }
        
        let request = URLRequest(url: url)

        return URLSession.DataTaskPublisher(request: request, session: .shared)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    throw ErrorModel(text: "API unknown error")
                }
                return data
            }
            .mapError { error in
                if let error = error as? ErrorModel {
                    return error
                } else {
                    return ErrorModel(text: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}


