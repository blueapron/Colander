//
//  MonthInfo.swift
//  Pods
//
//  Created by Bryan Oltman on 8/4/17.
//  Copyright © 2017 Blue Apron. All rights reserved.
//

#if canImport(UIKit)

import SwiftDate

struct MonthInfo {
    let startDate: DateInRegion
    let endDate: DateInRegion
    let firstDayWeekdayIndex: Int
    let numberOfDaysInMonth: Int

    init(forMonthContaining date: Date, with calendar: Calendar) throws {
        let workingDate = DateInRegion(date, region: Region(calendar: calendar, zone: calendar.timeZone, locale: calendar.locale ?? Locale.current))
        self.startDate = workingDate.dateAtStartOf(.month)
        self.endDate = workingDate.dateAtEndOf(.month)
        self.firstDayWeekdayIndex = calendar.component(.weekday, from: startDate.date) - 1 // 1-indexed to 0-indexed
        self.numberOfDaysInMonth = date.monthDays
    }
}

#endif
