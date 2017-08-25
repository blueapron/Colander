//
//  MonthInfo.swift
//  Pods
//
//  Created by Bryan Oltman on 8/4/17.
//  Copyright © 2017 Blue Apron. All rights reserved.
//

import Foundation
import SwiftDate

struct MonthInfo {
    let startDate: Date
    let endDate: Date
    let firstDayWeekdayIndex: Int
    let numberOfDaysInMonth: Int

    init(forMonthContaining date: Date, with calendar: Calendar = Calendar.gregorian) throws {
        guard let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: date)?.count else {
            throw DateError.Generic("Could not determine number of days in month for \(date)")
        }

        let beginningOfMonth = date.beginningOfMonth
        self.startDate = beginningOfMonth
        self.endDate = beginningOfMonth + numberOfDaysInMonth.days
        self.firstDayWeekdayIndex = calendar.component(.weekday, from: startDate) - 1 // 1-indexed to 0-indexed
        self.numberOfDaysInMonth = numberOfDaysInMonth
    }
}
