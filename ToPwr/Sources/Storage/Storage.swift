import Foundation
import Combine
import Common

public struct Storage {
    let defaults = UserDefaults.standard
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    
    public init(
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ){
        self.encoder = encoder
        self.decoder = decoder
    }
    
    public func saveContent<T: Codable> (
		content: T,
		key: String
	) ->  AnyPublisher<Void, ErrorModel> {
        if let data = encode(content: content) {
            defaults.set(data, forKey: key)
			return Just(())
				.setFailureType(to: ErrorModel.self)
				.eraseToAnyPublisher()
        }
		return Fail(error: ErrorModel.init(text: "Error saving content"))
			.eraseToAnyPublisher()
    }
    
    public func loadContent<T: Codable> (
		type: T.Type,
		key: String
	) -> Just<T?> {
        if let loadData = defaults.object(forKey: key) as? Data {
            return Just(decode(data: loadData, type: type.self))
        } else {
            return Just(nil)
        }
    }
	
	public func deleteContent(key: String) {
		defaults.removeObject(forKey: key)
	}
    
    private func encode<T: Codable> (content: T) -> Data?{
        return try? encoder.encode(content)
    }
    
    private func decode<T: Codable> (data: Data, type: T.Type) -> T? {
        return try? decoder.decode(type.self, from: data)
    }
}


public enum StorageKeys: String, CaseIterable {
	case apiVersion = "apiVersion"
}
