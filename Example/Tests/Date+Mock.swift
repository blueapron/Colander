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
        let c = DateComponents(year: year, month: month, day: day, hour: hour)
        let dateInRegion : DateInRegion = DateInRegion(components: c, region: nil)!
        return dateInRegion.date
    }
}
