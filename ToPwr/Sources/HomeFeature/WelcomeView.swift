import Foundation
import SwiftUI
import Common

public struct WelcomeView: View {
    let date: Date
    let isEvenWeek: Bool
    
    public init(){
        self.date = Date()
        let weekOfYear = Calendar.current.component(.weekOfYear, from: Date.init(timeIntervalSinceNow: 0))
        self.isEvenWeek = (weekOfYear % 2 == 0) ? true : false
    }
    
    public var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("Cześć, miło Cię widzieć")
                Text(dayString())
                    .fontWeight(.bold)
            }
            .padding([.top, .bottom])
        }
    }
    
    private func dayString() -> String {
        var text: String = "w "
        var textDay: String = ""
        
        if let day = Calendar.current.dateComponents([.weekday], from: Date()).weekday {
            switch day {
            case 1:
                if isEvenWeek {
                    textDay = "parzystą Niedzielę!"
                } else {
                    textDay = "nieparzystą Niedzielę!"
                }
            case 2:
                if isEvenWeek {
                    textDay = "parzysty Poniedziałek!"
                } else {
                    textDay = "nieparzysty Poniedziałek!"
                }
            case 3:
                if isEvenWeek {
                    textDay = "parzysty Wtorek!"
                } else {
                    textDay = "nieparzysty Wtorek!"
                }
            case 4:
                if isEvenWeek {
                    textDay = "parzystą Środę!"
                } else {
                    textDay = "nieparzystą Środę!"
                }
            case 5:
                if isEvenWeek {
                    textDay = "parzysty Czwartek!"
                } else {
                    textDay = "nieparzysty Czwartek!"
                }
            case 6:
                if isEvenWeek {
                    textDay = "parzysty Piątek!"
                } else {
                    textDay = "nieparzysty Piątek!"
                }
            case 7:
                if isEvenWeek {
                    textDay = "parzystą Sobotę!"
                } else {
                    textDay = "nieparzystą Sobotę!"
                }
            default:
                if isEvenWeek {
                    textDay += "parzysty Niezidentyfikowany dzień! "
                } else {
                    textDay += "nieparzysty Niezidentyfikowany dzień! "
                }
            }
        } else {
            text += "Niezidentyfikowany dzień! "
        }
        return text + textDay
    }
}
