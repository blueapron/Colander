import SwiftDate

extension Calendar {
    static let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
}

extension Date {
    var beginningOfMonth: Date {
        return self.startOf(component: .month)
    }
    
    var beginningOfWeek: Date {
        return self.startOf(component: .weekOfMonth)
    }

    var endOfWeek: Date {
        let numWeekdays = Calendar.gregorian.weekdaySymbols.count
        return self + (numWeekdays - self.weekday).days
    }

    func isSameMonthAs(_ otherDate: Date) -> Bool {
        return year == otherDate.year && month == otherDate.month
    }
}
