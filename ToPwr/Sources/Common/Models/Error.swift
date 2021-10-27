import Foundation

public struct ErrorModel: Error, Equatable {
    var text: String
    
    public init(
        text: String = ""
    ) {
        self.text = text
    }
}
