//
//  MonthInfo.swift
//  Pods
//
//  Created by Bryan Oltman on 8/4/17.
//  Copyright © 2017 Blue Apron. All rights reserved.
//

import Foundation

enum DateError: Error {
    case Generic(String)
}

struct MonthInfo {
    let startDate: Date
    let firstDayWeekdayIndex: Int
    let numberOfDaysInMonth: Int

    init(forMonthContaining date: Date) throws {
        guard let numberOfDaysInMonth = Calendar.gregorian.range(of: .day, in: .month, for: date)?.count else {
            throw DateError.Generic("Could not determine number of days in month for \(date)")
        }
        guard let beginningOfMonth = date.beginningOfMonth else {
            throw DateError.Generic("Could not determine the beginning of the month for \(date)")
        }

        self.startDate = beginningOfMonth
        self.firstDayWeekdayIndex = Calendar.gregorian.component(.weekday, from: startDate) - 1 // 1-indexed to 0-indexed
        self.numberOfDaysInMonth = numberOfDaysInMonth
    }
}
