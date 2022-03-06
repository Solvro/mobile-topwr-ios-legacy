import Foundation

public enum Strings {}

public extension Strings {
    enum Tabs {}
    enum HomeLists {}
    enum WelcomeDays {}
    enum Other {}
}

public extension Strings.Tabs {
    static let home = translation(from: "home_bar_item")
    static let map = translation(from: "map_bar_item")
    static let faculties = translation(from: "faculties_bar_item")
    static let clubs = translation(from: "clubs_bar_item")
    static let informations = translation(from: "informations_bar_item")
}

public extension Strings.HomeLists {
    static let scienceClubsTitle = translation(from: "science_list_title")
    static let departmentListTitle = translation(from: "department_list_title")
    static let departmentListButton = translation(from: "department_list_button")
    static let buildingListTitle = translation(from: "building_list_title")
    static let buildingListButton = translation(from: "building_list_button_title")
    static let whatsnewListTitle = translation(from:"whatsnew_list_title")
    static let infosListTitle = translation(from:"infos_list_title")
}

public extension Strings.WelcomeDays {
    static let evenSunday = translation(from: "welcome_view_even_sunday")
    static let oddSunday = translation(from: "welcome_view_odd_sunday")
    static let evenMonday = translation(from: "welcome_view_even_monday")
    static let oddMonday = translation(from: "welcome_view_odd_monday")
    static let evenTuesday = translation(from: "welcome_view_even_tuesday")
    static let oddTuesday = translation(from: "welcome_view_odd_tuesday")
    static let evenWednesday = translation(from: "welcome_view_even_wednesday")
    static let oddWednesday = translation(from: "welcome_view_odd_wednesday")
    static let evenThursday = translation(from: "welcome_view_even_thursday")
    static let oddThursday = translation(from: "welcome_view_odd_thursday")
    static let evenFriday = translation(from: "welcome_view_even_friday")
    static let oddFriday = translation(from: "welcome_view_odd_friday")
    static let evenSaturday = translation(from: "welcome_view_even_saturday")
    static let oddSaturday = translation(from: "welcome_view_odd_saturday")
}

public extension Strings.Other {
    static let days = translation(from: "days_text")
    static let tillSessionStart = translation(from: "till_session_start")
    static let welcomeTitle = translation(from: "welcome_title")
    static let searching = translation(from: "searching")
    static let deanOffice = translation(from: "dean_office")
    static let contact = translation(from: "contact")
    static let aboutUs = translation(from: "about_us")
    static let fields = translation(from: "fields")
    static let readMore = translation(from: "read_more")
}

func translation(
    from key: String
) -> String {
    NSLocalizedString(key, comment: "")
}
