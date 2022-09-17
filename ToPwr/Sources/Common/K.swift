import SwiftUI

public struct K {
// MARK: - COLORS
    public struct Colors {
        public static let background = Color.white
        public static let white = Color.white
        public static let firstColorDark = Color(hex: "#E16257")
        public static let firstColorLight = Color(hex: "#FFA07E")
        public static let lightGray = Color(hex: "#f7f7f8")
        public static let red = Color(hex: "#DB2B10")
        public static let logoBlue = Color(hex: "3f6499")
        public static let firstGreen = Color(hex: "027c3d")
        public static let tagGrey = Color(hex: "D9DCE0")
        public static let dateDark = Color(hex: "2E405A")
        public static let shadowCounter = Color(hex: "#C62D2E")

        public static let gradient = LinearGradient(
            colors: [K.Colors.firstColorLight, K.Colors.firstColorDark],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    public struct SearchColors {
        public static let darkGrey = Color(hex: "#979fac")
        public static let lightGray = Color(hex: "#f7f7f8")
        public static let textColor = Color(hex: "#e56353")
    }
    
    public struct CellColors {
        public static let scienceBackground = Color(hex: "#F7F7F8")
		public static let scienceBackgroundSelected = Color(hex: "#F67448")
    }
    
    public struct MapColors {
        public static let buildings1 = Color(hex: "#eae9e8")
        public static let buildings2 = Color(hex: "#f5e9d3")
    }
    
    public struct FontColors {
        public static let primary = Color(hex: "#293241")
    }
    
    static let defaultGradient: GradientColor = {
        GradientColor(
            id: 9999,
            gradientFirst: "#BFBEBE",
            gradientSecond: "#868585"
        )
    }()
    //MARK: - IMAGES
    public struct Images {
        public static let logoColor = Image("AppLogoColor", bundle: .module)
        public static let logoTemplate = Image("LogoTemplate", bundle: .module)
    }
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

public struct SplashBackgroundModifier: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        ZStack {
            K.Colors.gradient
                .edgesIgnoringSafeArea(.all)
            content
        }
    }
}


//MARK: - FONTS
public extension Font {
    static let appBoldTitle1 = Font.custom("Rubik-Bold", size: 20)
    static let appMediumTitle1 = Font.custom("Rubik-Medium", size: 20)
    static let appRegularTitle1 = Font.custom("Rubik-Regular", size: 20)
    static let appBoldTitle2 = Font.custom("Rubik-Bold", size: 17)
    static let appMediumTitle2 = Font.custom("Rubik-Medium", size: 17)
    static let appRegularTitle2 = Font.custom("Rubik-Regular", size: 17)
    static let appBoldTitle3 = Font.custom("Rubik-Bold", size: 15)
    static let appMediumTitle3 = Font.custom("Rubik-Medium", size: 15)
    static let appRegularTitle3 = Font.custom("Rubik-Regular", size: 15)
    static let appBoldTitle4 = Font.custom("Rubik-Bold", size: 13)
    static let appMediumTitle4 = Font.custom("Rubik-Medium", size: 13)
    static let appRegularTitle4 = Font.custom("Rubik-Regular", size: 13)
    static let appBoldTitle5 = Font.custom("Rubik-Bold", size: 12)
    static let appRegularTitle5 = Font.custom("Rubik-Regular", size: 12)
    static let appBoldTitle6 = Font.custom("Rubik-Bold", size: 11)
    static let appRegularTitle6 = Font.custom("Rubik-Regular", size: 11)
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
