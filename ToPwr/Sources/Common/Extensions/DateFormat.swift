import Foundation

public enum DateFormat {
    public enum ISO8601 {
        /// "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        /// 2020-01-24T13:28:20.005+0100
        public static let full = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        /// "yyyy-MM-dd'T'HH:mm:ssZ"
        /// 2020-01-24T13:28:20+0100
        public static let fullWithNoDecimals = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        /// "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        /// 2020-01-24T13:28:20.005+01:00
        public static let fullWithSemiColonInZone = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        /// "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        /// "2021-02-04T12:19:28+01:00"
        public static let fullWithSemiColonInZoneAndNoDecimals = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    }

    /// "yyyy-MM-dd"
    public static let date = "yyyy-MM-dd"
    /// "yyyy.MM.dd"
    public static let dateWithDots = "yyyy.MM.dd"
    /// "HH.mm"
    public static let time = "HH.mm"
    /// "MMMM"
    public static let fullMonth = "MMMM"
    /// "d. MMM"
    public static let dayAndShortMonth = "d. MMM"
    /// "EEE"
    public static let shortDay = "EEE"
}
