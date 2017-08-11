//
//  MonthInfoSpec.swift
//  CalendarView
//
//  Created by Bryan Oltman on 8/4/17.
//  Copyright © 2017 Blue Apron. All rights reserved.
//

import Quick
import Nimble
import SwiftDate
@testable import Colander

class MonthInfoSpec: QuickSpec {
    override func spec() {
        describe("init") {
            it("Correctly decides firstDayWeekdayIndex and number of days for a 31-day month") {
                // Today
                let monthInfo = try! MonthInfo(forMonthContaining: Date.mockDateFrom(year: 2017, month: 8, day: 4))

                // August 1, 2017 is a Tuesday
                expect(monthInfo.firstDayWeekdayIndex).to(equal(2))

                // August has 31 days
                expect(monthInfo.numberOfDaysInMonth).to(equal(31))
            }

            it("Correctly decides firstDayWeekdayIndex and number of days for a 30-day month") {
                // June 25, 2017
                let monthInfo = try! MonthInfo(forMonthContaining: Date.mockDateFrom(year: 2017, month: 6, day: 25))

                // Juen 1, 2017 is a Thursday
                expect(monthInfo.firstDayWeekdayIndex).to(equal(4))

                // June has 30 days
                expect(monthInfo.numberOfDaysInMonth).to(equal(30))
            }

            it("Correctly decides firstDayWeekdayIndex and number of days for a normal February") {
                // February 10, 2017
                let monthInfo = try! MonthInfo(forMonthContaining: Date.mockDateFrom(year: 2017, month: 2, day: 10))

                // February 1, 2017 is a Tuesday
                expect(monthInfo.firstDayWeekdayIndex).to(equal(3))

                // Feburary 2017 has 28 days
                expect(monthInfo.numberOfDaysInMonth).to(equal(28))
            }

            it("Correctly decides firstDayWeekdayIndex and number of days for a leap year February") {
                // February 14, 2016
                let monthInfo = try! MonthInfo(forMonthContaining: Date.mockDateFrom(year: 2016, month: 2, day: 14))

                // February 1, 2016 is a Monday
                expect(monthInfo.firstDayWeekdayIndex).to(equal(1))

                // Feburary 2017 has 28 days
                expect(monthInfo.numberOfDaysInMonth).to(equal(29))
            }
        }
    }
}
