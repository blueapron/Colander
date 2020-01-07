import SwiftDate

internal extension Calendar {
    static let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
}

internal extension Date {
    var beginningOfMonth: Date {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        if let timeZone = TimeZone(secondsFromGMT: 0) {
            calendar.timeZone = timeZone
        }
        var firstDayOfStartMonth = calendar.dateComponents( [.era, .year, .month], from: self)
        firstDayOfStartMonth.day = 1
        return calendar.date(from: firstDayOfStartMonth) ?? Date.nowAt(.startOfMonth)
    }
    
    var beginningOfWeek: Date {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        if let timeZone = TimeZone(secondsFromGMT: 0) {
            calendar.timeZone = timeZone
        }
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) ?? Date.nowAt(.startOfWeek)
    }

    var endOfWeek: Date {
        let numWeekdays = Calendar.gregorian.weekdaySymbols.count
        return self + (numWeekdays - self.weekday).days
    }

    func isSameMonthAs(_ otherDate: Date) -> Bool {
        return year == otherDate.year && month == otherDate.month
    }
}
