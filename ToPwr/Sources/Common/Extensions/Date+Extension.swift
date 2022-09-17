import Foundation

public extension Date {
    init(
        year: Int,
        month: Int,
        day: Int
    ) {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.timeZone = TimeZone(abbreviation: "JST") // Japan Standard Time
        dateComponents.hour = 12
        dateComponents.minute = 00

        // Create date from components
        let userCalendar = Calendar(identifier: .gregorian) // since the components above (like year 1980) are for Gregorian
        let someDateTime = userCalendar.date(from: dateComponents)
        self = someDateTime!
    }
}

//MARK: - toString
public extension Date {
    func toString(_ format: String = DateFormat.dateWithDots) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
