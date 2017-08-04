//
//  CalendarViewModel.swift
//  Pods
//
//  Created by Bryan Oltman on 8/4/17.
//  Copyright © 2017 Blue Apron. All rights reserved.
//

import Foundation
import SwiftDate

public protocol Dated {
    var date: Date? { get set }
}

class CalendarViewModel {
    let startDate: Date
    let endDate: Date
    let monthInfos: [MonthInfo]
    let showLeadingDays: Bool
    let showTrailingDays: Bool
    fileprivate let daysPerWeek = Calendar.gregorian.weekdaySymbols.count

    init(startDate: Date, endDate: Date, showLeadingDays: Bool = true, showTrailingDays: Bool = true) throws {
        self.startDate = startDate
        self.endDate = endDate
        self.showLeadingDays = showLeadingDays
        self.showTrailingDays = showTrailingDays
        self.monthInfos = try CalendarViewModel.makeMonthInfos(startDate: startDate, endDate: endDate)
    }

    static func numberOfSectionsNeededFor(startDate: Date, endDate: Date) -> Int {
        let monthSpan = endDate.month - startDate.month
        let yearSpan = endDate.year - startDate.year
        return yearSpan * 12 + monthSpan + 1
    }

    static func makeMonthInfos(startDate: Date, endDate: Date) throws -> [MonthInfo] {
        guard let monthStartDate = startDate.beginningOfMonth else { return [] }
        let sections = (0..<(numberOfSectionsNeededFor(startDate: startDate, endDate: endDate)))
        return try sections.map { try MonthInfo(forMonthContaining: monthStartDate + $0.months) }
    }

    func date(at indexPath: IndexPath) -> Date? {
        let monthInfo = monthInfos[indexPath.section]
        var dayOffset = monthInfo.firstDayWeekdayIndex
        var numberOfDays = monthInfo.numberOfDaysInMonth
        if !showLeadingDays && indexPath.section == 0 {
            numberOfDays -= firstDisplayDate(for: monthInfo, showLeadingDays: showLeadingDays).day
            dayOffset = 1
        }
        let dayDifference = indexPath.item - dayOffset
        if dayDifference < 0 || dayDifference >= monthInfo.numberOfDaysInMonth {
            return nil
        }

        return monthInfo.startDate + (indexPath.item - dayOffset).days
    }

    func indexPath(from date: Date) -> IndexPath {
        let section = CalendarViewModel.numberOfSectionsNeededFor(startDate: startDate, endDate: date) - 1
        let monthInfo = monthInfos[section]
        return IndexPath(item: date.day + monthInfo.firstDayWeekdayIndex - 1, section: section)
    }

    func firstDisplayDate(for monthInfo: MonthInfo, showLeadingDays: Bool) -> Date {
        // EffectiveStartDate is the beginning of the week including startDate
        let startDate = monthInfo.startDate
        if showLeadingDays {
            return startDate
        } else {
            return startDate - (startDate.weekday - 1).days
        }
    }

    func numberOfItems(in section: Int) -> Int {
        let monthInfo = monthInfos[section]
        var numberOfDays = monthInfo.numberOfDaysInMonth
        var offset = monthInfo.firstDayWeekdayIndex
        let effectiveStartDate = firstDisplayDate(for: monthInfo, showLeadingDays: showLeadingDays)
        let isFirstMonth = section == 0
        let isLastMonth = section == monthInfos.count - 1
        // If we're in our first month, don't show weeks leading up to but not including startDate
        if !showLeadingDays && isFirstMonth {
            numberOfDays -= effectiveStartDate.day
            offset = 1
        }

        if !showTrailingDays && isLastMonth {
            let daysAfterEndDate = daysPerWeek - endDate.weekday
            numberOfDays = endDate.day + daysAfterEndDate
        }

        let requiredRows = ceil((Double(numberOfDays) + Double(offset)) / Double(daysPerWeek))

        // We display full rows for every week we display, even if the current month starts or ends before the week.
        return Int(requiredRows) * daysPerWeek
    }
}
