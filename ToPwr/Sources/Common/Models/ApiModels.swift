import Foundation
import ComposableArchitecture
import AVFoundation

// MARK: - Session day
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

// MARK: - Department
public struct Department: Codable, Equatable {
    public var id: Int
    public var name: String?
    public var code: String?
    public var description: String?
    public var website: String?
    public var locale: String?
    public var socialMedia: [SocialMedia?]
    public var adress: Address?
    public var fieldOfStudy: [FieldOfStudy]
    public var photo: Photo?
    public var logo: Photo?
    public var clubs: [ScienceClub?]

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "Name"
        case code = "Code"
        case description = "Description"
        case website = "Website"
        case locale = "locale"
        case socialMedia = "SocialMedia"
        case adress = "Address"
        case fieldOfStudy = "FieldOfStudy"
        case photo = "Photo"
        case logo = "Logo"
        case clubs = "scientific_circles"
    }
}

// MARK: - Address
public struct Address: Codable, Equatable {
    public let id: Int
    public let address: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case address = "Address"
    }
}

// MARK: - FieldOfStudy
public struct FieldOfStudy: Codable, Equatable {
    public let id: Int
    public let name: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "Name"
    }
}

// MARK: - Photo
public struct Photo: Codable, Equatable {
    public let id: Int
    public let name: String
    public let url: String
    public let previewURL: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case url = "url"
        case previewURL = "previewUrl"
    }
}

// MARK: - Formats
public struct Formats: Codable, Equatable {
    public let large: Format?
    public let small: Format?
    public let medium: Format?
    public let thumbnail: Format?

    enum CodingKeys: String, CodingKey {
        case large = "large"
        case small = "small"
        case medium = "medium"
        case thumbnail = "thumbnail"
    }
}

public struct Format: Codable, Equatable {
    public let ext: String?
    public let url: String?
    public let hash: String?
    public let mime: String?
    public let name: String?
    public let path: String?
    public let size: Int?
    public let width: Int?
    public let height: Int?
    public let provider: Provider?
    
    enum CodingKeys: String, CodingKey {
        case ext = "ext"
        case url = "url"
        case hash = "hash"
        case mime = "mime"
        case name = "name"
        case path = "path"
        case size = "size"
        case width = "width"
        case height = "height"
        case provider = "provider_metadata"
    }
}

public struct Provider: Codable, Equatable {
    let id: String?
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "public_id"
        case type = "resource_type"
    }
}

//MARK: - Social Media
public struct SocialMedia: Codable, Equatable {
    public let id: Int
    public let name: String?
    public let link: String?
    public let icon: Photo?
    
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "Name"
        case link = "Link"
        case icon = "Icon"
       
    }
}

//MARK: - Science Clubs
public struct ScienceClub: Codable, Equatable {
    public let id: Int
    public let name: String?
    public let department: Int?
    public let description: String?
    public let locale: String
    public let contact: [Contact?]
    public let socialMedia: [SocialMedia?]
    public let tag: [Tag?]
    public let photo: Photo?
    
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "Name"
        case department = "department"
        case description = "Description"
        case locale = "locale"
        case contact = "Contact"
        case socialMedia = "SocialMedia"
        case tag = "Tag"
        case photo = "Photo"
    }
}

public struct Tag: Codable, Equatable {
    public let id: Int
    public let name: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "Name"
    }
}

public struct Contact: Codable, Equatable {
    public let id: Int
    public let name: String?
    public let number: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "Name"
        case number = "Number"
    }
}

#if DEBUG
//MARK: - MOCKS
public extension Department {
    static let mock: Self = .init(
        id: 1,
        name: "Wydział kosmosu i trawy",
        code: "W69",
        description: "Jaramy trawę w kosmosie",
        website: nil,
        locale: nil,
        socialMedia: [],
        adress: nil,
        fieldOfStudy: [],
        photo: nil,
        logo: nil,
        clubs: []
    )
    
    static func mock(id: Int) -> Self {
        .init(
            id: 1,
            name: "Wydział kosmosu i trawy",
            code: "W69",
            description: "Jaramy trawę w kosmosie",
            website: nil,
            locale: nil,
            socialMedia: [],
            adress: nil,
            fieldOfStudy: [],
            photo: nil,
            logo: nil,
            clubs: []
        )
    }
}


#endif
