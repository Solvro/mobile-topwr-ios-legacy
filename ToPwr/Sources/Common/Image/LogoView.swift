import Foundation
import SwiftUI

public struct LogoView: View {
    
    public init(){}
    
    public var body: some View {
        Image("AppLogoColor", bundle: .module)
            .resizable()
    }
}
