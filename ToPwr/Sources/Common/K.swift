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
    
    public struct FontColors {
        public static let primary = Color(hex: "#293241")
    }
    //MARK: - IMAGES
    public struct Images {
        public static let logoColor = Image("AppLogoColor", bundle: .module)
        public static let logoTemplate = Image("LogoTemplate", bundle: .module)
    }

//MARK: - Background modifier
    public struct DefaultBackgroundColor: ViewModifier {
        public init() {}
        public func body(content: Content) -> some View {
            ZStack {
                K.Colors.background
                    .edgesIgnoringSafeArea(.all)
                content
            }
        }
    }
}

//MARK: - FONTS
public extension Font {
    static let appBoldTitle1 = Font.system(size: 20, weight: .bold)
    static let appRegularTitle1 = Font.system(size: 20, weight: .regular)
    static let appBoldTitle2 = Font.system(size: 17, weight: .bold)
    static let appRegularTitle2 = Font.system(size: 17, weight: .regular)
    static let appBoldTitle3 = Font.system(size: 15, weight: .bold)
    static let appRegularTitle3 = Font.system(size: 15, weight: .regular)
    static let appBoldTitle4 = Font.system(size: 13, weight: .bold)
    static let appRegularTitle4 = Font.system(size: 13, weight: .regular)
    static let appBoldTitle5 = Font.system(size: 12, weight: .bold)
    static let appRegularTitle5 = Font.system(size: 12, weight: .regular)
    static let appBoldTitle6 = Font.system(size: 11, weight: .bold)
    static let appRegularTitle6 = Font.system(size: 11, weight: .regular)
}

//MARK: - PREVIEW
#if DEBUG
struct FontsView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("appBoldTitle1")
                    .font(.appBoldTitle1)
                Text("appRegularTitle1")
                    .font(.appRegularTitle1)
                Text("appBoldTitle2")
                    .font(.appBoldTitle2)
                Text("appRegularTitle2")
                    .font(.appRegularTitle2)
                Text("appBoldTitle3")
                    .font(.appBoldTitle3)
                Text("appRegularTitle3")
                    .font(.appRegularTitle3)
                Text("appBoldTitle4")
                    .font(.appBoldTitle4)
            }
            VStack {
                Text("appRegularTitle4")
                    .font(.appRegularTitle4)
                Text("appBoldTitle5")
                    .font(.appBoldTitle5)
                Text("appRegularTitle5")
                    .font(.appRegularTitle5)
                Text("appBoldTitle6")
                    .font(.appBoldTitle6)
                Text("appRegularTitle6")
                    .font(.appRegularTitle6)
            }
        }
    }
}

struct FontsView_Previews: PreviewProvider {
    static var previews: some View {
        FontsView()
    }
}
#endif
