import Foundation
import SwiftDate

extension Date {
    /// Creates a `Date` instance with given components
    ///
    /// - Parameters:
    ///   - year: the desired year
    ///   - month: the desired month
    ///   - day: the desired day
    /// - Returns: a new instance of `Date` with the given components
    static func mockDateFrom(year: Int, month: Int, day: Int, hour: Int = 0) -> Date {
        var components = DateComponents(year: year, month: month, day: day, hour: hour)
        // nsdate is timezone independent, essentially representing GMT,
        // so make sure the calendar is parsing the date in GMT as well
        if let timeZone = TimeZone(secondsFromGMT: 0) {
            components.timeZone = timeZone
        }
        let dateInRegion : DateInRegion = DateInRegion(components: components, region: nil)!
        return dateInRegion.date
    }
}
