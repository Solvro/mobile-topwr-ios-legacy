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
        case sessionDate = "endDate"
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
    public var infoSection: [InfoSection]
    public var adress: String?
    public var fieldOfStudy: [FieldOfStudy]
    public var color: GradientColor?
    public var logo: Photo?
    public var clubsID: [Int]
    public var latitude: Float?
    public var longitude: Float?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case code = "code"
        case description = "description"
        case website = "website"
        case locale = "locale"
        case infoSection = "infoSection"
        case adress = "addres"
        case fieldOfStudy = "fieldsOfStudy"
        case color = "color"
        case logo = "logo"
        case clubsID = "scientificCircles"
        case latitude = "latitude"
        case longitude = "longitude"
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
public struct FieldOfStudy: Codable, Equatable, Identifiable {
    public let id: Int
    public let name: String?
    public let name2: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "Name"
        case name2 = "name"
    }
}

// MARK: - Photo
public struct Photo: Codable, Equatable {
    public let id: Int
    public let name: String
    private let stringUrl: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case stringUrl = "url"
    }
}

//MARK: - Social Media
public struct LinkComponent: Codable, Equatable, Identifiable {
    public let id: Int
    public let name: String?
    public let link: String?
    public let icon: Photo?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "LinkText"
        case link = "Value"
        case icon = "Icon"
       
    }
}

//MARK: - Info Section
public struct InfoSection: Codable, Equatable, Identifiable {
    public let id: Int
    public let name: String?
    public let info: [InfoComponent]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case info = "info"
    }
}

//MARK: - Info Component
public struct InfoComponent: Codable, Equatable, Identifiable {
    public let id: Int
    public let value: String?
    public let icon: Photo?
    private let stringType: String?
    public let label: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case value = "value"
        case icon = "icon"
        case stringType = "type"
        case label = "visibleText"
    }
}

public extension InfoComponent {
    enum InfoType: String {
        case phone = "PhoneNumber"
        case addres = "Addres"
        case website = "Website"
        case email = "Email"
        case other = "other"
    }
    
    var type: InfoType {
        InfoType(rawValue: stringType ?? "other") ?? .other
    }
}

//MARK: - Science Clubs
public struct ScienceClub: Codable, Equatable {
    public let id: Int
    public let name: String?
    public let department: Int?
    public let description: String?
    public let locale: String
    public let infoSection: [InfoSection]
    public let tags: [Tag]
    public let photo: Photo?
    public let background: Photo?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case department = "department"
        case description = "description"
        case locale = "locale"
        case infoSection = "infoSection"
        case tags = "tags"
        case photo = "photo"
        case background = "backgroundPhoto"
    }
}

public struct Tag: Codable, Equatable {
    public let id: Int
    public let name: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }
}

public struct Contact: Codable, Equatable, Identifiable {
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
        case photo = "photo"
    }
}

//MARK: - GradientColor
public struct GradientColor: Codable, Equatable {
    public let id: Int
    public let gradientFirst: String?
    public let gradientSecond: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case gradientFirst = "gradientFirst"
        case gradientSecond = "gradientSecond"
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

public struct Version: Codable, Equatable {
    public let id: String
    
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
    }
}

// MARK: - WhatsNew
public struct WhatsNew: Codable, Equatable, Identifiable {
    public let id: Int
    public let title: String
    public let description: String?
    public let infoSection: [InfoSection]
    public let photo: Photo?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case description = "description"
        case infoSection = "infoSection"
        case photo = "photo"
    }
}

// MARK: - EXTENSIONS
public extension WeekDay {
    var date: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MM-dd"
        return dateFormatter.date(from: dateString)
    }
}

public extension Photo {
    var url: URL? {
        URL(string: stringUrl)
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
        infoSection: [],
        adress: "",
        fieldOfStudy: [],
        color: nil,
        logo: nil,
        clubsID: []
    )
    
    static func mock(id: Int) -> Self {
        .init(
            id: 1,
            name: "Wydział kosmosu i trawy",
            code: "W69",
            description: "Jaramy trawę w kosmosie",
            website: nil,
            locale: nil,
            infoSection: [],
            adress: "",
            fieldOfStudy: [],
            color: nil,
            logo: nil,
            clubsID: []
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
        department: 5,
        description: "TEST",
        locale: "",
        infoSection: [],
        tags: [],
        photo: nil,
        background: nil
    )
}

public extension WhatsNew {
    static let mock: Self = .init(
        id: 123,
        title: "Title",
        description: "description",
        infoSection: [],
        photo: nil
    )
}
#endif
