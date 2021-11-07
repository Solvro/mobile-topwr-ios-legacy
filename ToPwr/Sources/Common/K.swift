import SwiftUI

public struct K {
// MARK: - COLORS
    public struct Colors {
//      public static let background = Color("backgroundGray", bundle: .module)
        public static let background = Color.white
        public static let white = Color.white
        public static let firstColorDark = Color(hex: "#e56353")
        public static let firstColorLight = Color(hex: "#ff9f7e")
    }
    
    public struct CellColors {
        public static let scienceBackground = Color(hex: "#F7F7F8")
    }
    
//MARK: - IMAGES
    public struct Images {
//        public static let blackPropeller = Image("propeller_black", bundle: .module)
    }
}

//MARK: - FONTS
public extension Font {
    static let appBoldTitle1 = Font.system(size: 25, weight: .bold)
    static let appBoldTitle2 = Font.system(size: 22, weight: .bold)
    static let appBoldTitle3 = Font.system(size: 19, weight: .bold)
    static let appRegular1 = Font.system(size: 19, weight: .regular)
    static let appRegular2 = Font.system(size: 18, weight: .regular)
    
    //USAGE:
    ///Text("Example")
    ///    .font(.appFont)
}
