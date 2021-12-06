import SwiftUI

public struct Strings {
    
    public struct TabBar {
        public static let home = Text("Home", bundle: .module)
        public static let map = Text("Map", bundle: .module)
        public static let faculties = Text("Faculties", bundle: .module)
        public static let clubs = Text("Clubs", bundle: .module)
        public static let calculator = Text("Calculator", bundle: .module)
    }
    
    public struct DaysToSessionView {
        public static let days = Text("days", bundle: .module)
        public static let tillStart = Text("before the session starts", bundle: .module)
    }
    
    public struct WelcomeView {
        public static let welcomeText = Text("Hi, good to see you!", bundle: .module)
    }
    
    public struct BuildingList {
        public static let title = Text("Buildings", bundle: .module)
        public static let button = Text("Map", bundle: .module)
    }
    
    public struct DepartmentList {
        public static let welcomeText = Text("Faculties", bundle: .module)
        public static let button  = Text("List", bundle: .module)
    }
    
    public struct ScienceClubList {
        public static let title = Text("Science Clubs", bundle: .module)
    }
    
    public struct Search {
        public static let searching = translation(from: "searching")
        
    }
}

import Foundation

func translation(
    from key: String
) -> String {
    NSLocalizedString(key, comment: "")
}
