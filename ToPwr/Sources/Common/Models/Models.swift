import Foundation
import ComposableArchitecture

//Session Day
public struct SessionDay: Codable, Equatable {
    public var id: Int
    public var created: String
    public var updated: String
    public var sessionDate: String
    public var published: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case created = "created_at"
        case updated = "updated_at"
        case sessionDate = "EndDate"
        case published = "published_at"
    }
}

