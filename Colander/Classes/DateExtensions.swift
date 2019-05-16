import SwiftDate

extension Calendar {
    static let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
}

extension Date {
    var beginningOfMonth: Date {
        var firstDayOfStartMonth = Calendar.gregorian.dateComponents( [.era, .year, .month], from: self)
        firstDayOfStartMonth.day = 1
        return Calendar.gregorian.date(from: firstDayOfStartMonth) ?? Date.nowAt(.startOfMonth)
    }
    
    var beginningOfWeek: Date {
        return Calendar.gregorian.date(from: Calendar.gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) ?? Date.nowAt(.startOfWeek)
    }

    var endOfWeek: Date {
        let numWeekdays = Calendar.gregorian.weekdaySymbols.count
        return self + (numWeekdays - self.weekday).days
    }

    func isSameMonthAs(_ otherDate: Date) -> Bool {
        return year == otherDate.year && month == otherDate.month
    }
}
