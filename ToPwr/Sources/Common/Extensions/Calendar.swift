import Foundation

public extension Date {
    func daysBetween(start: Self, end: Self) -> Int {
       Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
}
