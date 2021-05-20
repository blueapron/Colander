import Foundation
import SwiftDate
@testable import Colander

extension Date {
    /// Creates a `Date` instance with given components
    ///
    /// - Parameters:
    ///   - year: the desired year
    ///   - month: the desired month
    ///   - day: the desired day
    /// - Returns: a new instance of `Date` with the given components
    static func mockDateFrom(year: Int, month: Int, day: Int, hour: Int = 0, calendar: Calendar = .gregorian) -> Date {
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}
