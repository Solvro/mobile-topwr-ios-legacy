import Foundation
import Combine
import ComposableArchitecture
import Common
import StoreKit

public struct Api {
    // MARK: API TYPE (stage/prod)
	let type: BackendURL = .init(type: .prod)
    private let session: URLSession
    
    public init() {
        self.session = URLSession.shared
    }
    
    public func fetch(
        path: String,
        order: String? = nil,
        start: Int? = nil,
        limit: Int? = nil
    ) -> AnyPublisher<Data, ErrorModel> {
        guard let url: URL = .init(
            string: type.urlString + path
        )
        else {
            return Fail(error: ErrorModel(text: "Couldn't generate url"))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        var urlComponents = URLComponents(string: url.absoluteString)!
        if let order = order {
            urlComponents.queryItems?.append(URLQueryItem(name: "_sort", value: "\(order)"))
        }
        if let start = start {
            urlComponents.queryItems?.append(URLQueryItem(name: "_start", value: "\(start)"))
        }
        if let limit = limit {
            urlComponents.queryItems?.append(URLQueryItem(name: "_limit", value: "\(limit)"))
        }
        request = URLRequest(url: urlComponents.url!)
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

struct BackendURL {
    public let urlString: String
    enum ApiType {
    case prod
    case stage
    }
    
    public init(
        type: ApiType
    ) {
        if type == .stage {
            urlString = BackedAPIs.stage
        } else {
            urlString = BackedAPIs.prod
        }
    }
}

enum BackedAPIs {
    static let stage = "https://to-pwr-backend.herokuapp.com"
    static let prod = "http://217.182.78.179:1337"
}

