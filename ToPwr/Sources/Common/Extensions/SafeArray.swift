import Foundation

public extension Array {
    /// safe unpacking value from string
    /// - returns optional value
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        return self[index]
    }
}
