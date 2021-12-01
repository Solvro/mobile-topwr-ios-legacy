import SwiftUI

public struct K {
// MARK: - COLORS
    public struct Colors {
        public static let background = Color.white
        public static let white = Color.white
        public static let firstColorDark = Color(hex: "#E16257")
        public static let firstColorLight = Color(hex: "#FFA07E")
    }
    
    public struct SearchColors {
        public static let darkGray = Color(hex: "#979fac")
        public static let lightGray = Color(hex: "#f7f7f8")
        public static let textColor = Color(hex: "#e56353")
    }
    
    public struct CellColors {
        public static let scienceBackground = Color(hex: "#F7F7F8")
    }
    
    public struct MapColors {
        public static let buildings1 = Color(hex: "#eae9e8")
        public static let buildings2 = Color(hex: "#f5e9d3")
    }
    
    //MARK: - IMAGES
    public struct Images {
        public static let logoColor = Image("AppLogoColor", bundle: .module)
        public static let logoTemplate = Image("LogoTemplate", bundle: .module)
    }
}

//MARK: - FONTS
public extension Font {
    static let appBoldTitle1 = Font.system(size: 25, weight: .bold)
    static let appBoldTitle2 = Font.system(size: 22, weight: .bold)
    static let appBoldTitle3 = Font.system(size: 19, weight: .bold)
    static let appRegular1 = Font.system(size: 19, weight: .regular)
    static let appRegular2 = Font.system(size: 18, weight: .regular)
}
