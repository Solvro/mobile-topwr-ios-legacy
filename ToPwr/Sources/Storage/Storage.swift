import Foundation

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
    
    public func saveContent<T: Codable> (content: T, key: String) {
        if let data = decode(content: content) {
            defaults.set(data, forKey: key)
            print("saved")
        }
    }
    
    public func loadContent<T: Codable> (type: T.Type, key: String) -> T? {
        if let loadData = defaults.object(forKey: key) as? Data {
            return encode(data: loadData, type: type.self)
        } else {
            return nil
        }
    }
    
    private func decode<T: Codable> (content: T) -> Data?{
        return try? encoder.encode(content)
    }
    
    private func encode<T: Codable> (data: Data, type: T.Type) -> T? {
        return try? decoder.decode(type.self, from: data)
    }
}
