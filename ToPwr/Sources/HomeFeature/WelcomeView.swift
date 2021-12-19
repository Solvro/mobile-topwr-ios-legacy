import Foundation
import SwiftUI
import Common

public struct WelcomeView: View {
    let date: Date
    let exceptations: ExceptationDays?
    
    public init(
        exceptations: ExceptationDays?
    ) {
        self.date = Date()
        self.exceptations = exceptations
    }
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(Strings.Other.welcomeTitle)
                    .font(.appRegularTitle1)
                Text(
                    getWelcomeText(
                        currentDate: date,
                        exceptations: exceptations
                    )
                )
                    .font(.appBoldTitle1)
            }
            .foregroundColor(K.FontColors.primary)
            Spacer()
        }
    }
}

//MARK: - Parity Enum
enum Parity {
    case even
    case odd
}

//MARK: - Date String logic
extension WelcomeView {
    fileprivate func getWelcomeText(
        currentDate: Date,
        exceptations: ExceptationDays?
    ) -> String {
        if let exceptationDay = exceptations?.isExceptation(date: currentDate) {
            guard let day = exceptationDay.dayNumber(),
                  let parity = exceptationDay.getParity() else {
                      return ""
                  }
            return dayString(day: day, parity: parity)
        } else {
            guard let day = Calendar.current.dateComponents([.weekday], from: currentDate).weekday else {
                return ""
            }
            let weekOfYear = (Calendar.current.component(.weekOfYear, from: currentDate) - 1)
            var parity: Parity {
                if (weekOfYear % 2 == 0) == true {
                    return .even
                } else {
                    return .odd
                }
            }
            return dayString(day: day, parity: parity)
        }
    }
    
    private func dayString(day: Int, parity: Parity) -> String {
        switch day {
        case 1:
            switch parity {
            case .even:
                return Strings.WelcomeDays.evenSunday
            case .odd:
                return Strings.WelcomeDays.oddSunday
            }
        case 2:
            switch parity {
            case .even:
                return Strings.WelcomeDays.evenMonday
            case .odd:
                return Strings.WelcomeDays.oddMonday
            }
        case 3:
            switch parity {
            case .even:
                return Strings.WelcomeDays.evenTuesday
            case .odd:
                return Strings.WelcomeDays.oddTuesday
            }
        case 4:
            switch parity {
            case .even:
                return Strings.WelcomeDays.evenWednesday
            case .odd:
                return Strings.WelcomeDays.oddWednesday
            }
        case 5:
            switch parity {
            case .even:
                return Strings.WelcomeDays.evenThursday
            case .odd:
                return Strings.WelcomeDays.oddThursday
            }
        case 6:
            switch parity {
            case .even:
                return Strings.WelcomeDays.evenFriday
            case .odd:
                return Strings.WelcomeDays.oddFriday
            }
        case 7:
            switch parity {
            case .even:
                return Strings.WelcomeDays.evenSaturday
            case .odd:
                return Strings.WelcomeDays.oddSaturday
            }
        default:
            return ""
        }
    }
}

//MARK: - WeekDay extension
extension WeekDay {
    ///returns number of day in week, starts from sunday -> 1
    func dayNumber() -> Int? {
        switch day {
        case "Sun":
            return 1
        case "Mon":
            return 2
        case "Tue":
            return 3
        case "Wen":
            return 4
        case "Thu":
            return 5
        case "Fri":
            return 6
        case "Sat":
            return 7
        default:
            return nil
        }
    }
    
    func getParity() -> Parity? {
        switch parity {
        case "Even":
            return .even
        case "Odd":
            return .odd
        default:
            return nil
        }
    }
}
