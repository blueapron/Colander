extension Calendar {
    static let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
}

extension Date {
    var beginningOfMonth: Date? {
        var firstDayOfStartMonth = Calendar.gregorian.dateComponents( [.era, .year, .month], from: self)
        firstDayOfStartMonth.day = 1
        return Calendar.gregorian.date(from: firstDayOfStartMonth)
    }

    func isSameMonthAs(_ otherDate: Date) -> Bool {
        return year == otherDate.year && month == otherDate.month
    }
}
