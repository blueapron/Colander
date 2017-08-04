//
//  MonthInfo.swift
//  Pods
//
//  Created by Bryan Oltman on 8/4/17.
//
//

import Foundation

enum DateError: Error {
    case Generic(String)
}

struct MonthInfo {
    let startDate: Date
    let firstDayWeekdayIndex: Int
    let numberOfDaysInMonth: Int

    init(startDate: Date) throws {
        guard let numberOfDaysInMonth = Calendar.gregorian.range(of: .day, in: .month, for: startDate)?.count else {
            throw DateError.Generic("Could not determine number of days in month for \(startDate)")
        }

        self.startDate = startDate
        self.firstDayWeekdayIndex = Calendar.gregorian.component(.weekday, from: startDate) - 1 // 1-indexed to 0-indexed
        self.numberOfDaysInMonth = numberOfDaysInMonth
    }

    func contains(index: Int) -> Bool {
        let range = firstDayWeekdayIndex..<(firstDayWeekdayIndex + numberOfDaysInMonth)
        return range.contains(index)
    }
}
