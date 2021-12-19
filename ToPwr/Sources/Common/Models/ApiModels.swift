import Foundation
import ComposableArchitecture
import AVFoundation
import SwiftUI

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
    public var color: GradientColor?
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
        case color = "Color"
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
//    public let department: Department?
    public let description: String?
    public let locale: String
    public let contact: [Contact]
    public let socialMedia: [SocialMedia]
    public let tag: [Tag]
    public let photo: Photo?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "Name"
//        case department = "department"
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

//MARK: - Maps
public struct Map: Codable, Equatable {
    public let id: Int
    public let name: String?
    public let code: String?
    public let latitude: Double?
    public let longitude: Double?
    public let description: String?
    public let address: Address?
    public let photo: Photo?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "Name"
        case code = "Code"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case description = "Description"
        case address = "Address"
        case photo = "Photo"
    }
}

//MARK: - GradientColor
public struct GradientColor: Codable, Equatable {
    public let id: Int
    public let gradientFirst: String?
    public let gradientSecond: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case gradientFirst = "GradientFirst"
        case gradientSecond = "GradientSecond"
    }
}

public extension GradientColor {
    var firstColor: Color {
        Color(hex: gradientFirst ?? "")
    }
    var secondColor: Color {
        Color(hex: gradientSecond ?? "")
    }
}

//MARK: - ExceptationDay
public struct ExceptationDays: Codable, Equatable {
    public let id: Int
    public let weekDays: [WeekDay]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case weekDays = "Weekday"
    }
    
    public func isExceptation(date: Date) -> WeekDay? {
        for day in weekDays {
            if let exceptation = day.date {
                if Calendar.current.compare(
                    date,
                    to: exceptation,
                    toGranularity: .day
                ) == .orderedSame {
                    return day
                }
            }
        }
        return nil
    }
}

public struct WeekDay: Codable, Equatable {
    public let dateString: String
    public let parity: String
    public let day: String
    
    enum CodingKeys: String, CodingKey {
        case dateString = "Date"
        case parity = "Parity"
        case day = "DayOfTheWeek"
    }
    
    var isEven: Bool {
        if parity == "Even" {
            return true
        } else {
            return false
        }
    }
}

public extension WeekDay {
    var date: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MM-dd"
        return dateFormatter.date(from: dateString)
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
        color: nil,
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
            color: nil,
            photo: nil,
            logo: nil,
            clubs: []
        )
    }
}

public extension Map {
    static let mock: Self = .init(
        id: 1,
        name: "Test Name",
        code: "B4",
        latitude: 15.6,
        longitude: 16.3,
        description: "Test description",
        address: nil,
        photo: nil
    )
}

public extension ScienceClub {
    static let mock: Self = .init(
        id: 1,
        name: "SOLVRO",
        description: "TEST",
        locale: "",
        contact: [],
        socialMedia: [],
        tag: [],
        photo: nil
    )
}
#endif
