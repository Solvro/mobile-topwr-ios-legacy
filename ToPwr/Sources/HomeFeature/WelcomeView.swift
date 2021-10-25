import Foundation
import SwiftUI
import Common

public struct WelcomeView: View {
    let date: Date
    let isEvenWeek: Bool
    
    public init(){
        self.date = Date()
        let weekOfYear = Calendar.current.component(.weekOfYear, from: Date.init(timeIntervalSinceNow: 0))
        if weekOfYear % 2 == 0 {
            self.isEvenWeek = true
        } else {
            self.isEvenWeek = false
        }
    }
    
    public var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("Cześć, miło Cię widzieć")
                Text(dayString())
                    .fontWeight(.bold)
            }
            .padding(20)
        }
    }
    
    private func dayString() -> String {
        var text: String = "w "
        
        if isEvenWeek {
            text += "parzysty "
        } else {
            text += "nieparzysty "
        }
        
        if let day = Calendar.current.dateComponents([.weekday], from: Date()).weekday {
            switch day {
            case 1:
                text += "Poniedziałek!"
            case 2:
                text += "Wtorek!"
            case 3:
                text += "Środę!"
            case 4:
                text += "Czwartek!"
            case 5:
                text += "Piątek!"
            case 6:
                text += "Sobotę!"
            case 7:
                text += "Niedzielę!"
            default:
                text += "Niezidentyfikowany dzień! "
            }
        } else {
            text += "Niezidentyfikowany dzień! "
        }
        return text
    }
}
