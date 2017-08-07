//
//  CalendarViewModelSpec.swift
//  CalendarView
//
//  Created by Bryan Oltman on 8/4/17.
//  Copyright © 2017 Blue Apron. All rights reserved.
//

import Quick
import Nimble
import SwiftDate
@testable import CalendarView

class CalendarViewModelSpec: QuickSpec {
    override func spec() {
        describe("init") {
            it("creates the correct month infos for a single month") {
                let startDate = Date.mockDateFrom(year: 2017, month: 8, day: 4)
                let endDate = startDate + 1.week
                let subject = try! CalendarViewModel(startDate: startDate, endDate: endDate)
                expect(subject.monthInfos.count).to(equal(1))
                let mockMonthInfo = try! MonthInfo(forMonthContaining: startDate)
                let monthInfo = subject.monthInfos.first!
                expect(monthInfo.startDate).to(equal(mockMonthInfo.startDate))
                expect(monthInfo.numberOfDaysInMonth).to(equal(mockMonthInfo.numberOfDaysInMonth))
            }

            func testCalendarViewModel(startDate: Date, endDate: Date) throws {
                let calendar = NSCalendar.current
                let components = calendar.dateComponents([.month], from: startDate, to: endDate)
                let expectedCount = (components.month ?? 0) + 1 // x months plus  in x years
                
                let subject = try CalendarViewModel(startDate: startDate, endDate: endDate)
                expect(subject.monthInfos.count).to(equal(expectedCount))
                for (i, monthInfo) in subject.monthInfos.enumerated() {
                    let mockMonthInfo = try! MonthInfo(forMonthContaining: startDate + i.months)
                    expect(monthInfo.startDate).to(equal(mockMonthInfo.startDate))
                    expect(monthInfo.numberOfDaysInMonth).to(equal(mockMonthInfo.numberOfDaysInMonth))
                }
            }
            
            it("creates the correct month infos for multiple months in the same year") {
                let startDate = Date.mockDateFrom(year: 2017, month: 8, day: 4)
                let endDate = startDate + 3.months
                try! testCalendarViewModel(startDate: startDate, endDate: endDate)
            }

            it("creates the correct month infos for multiple months in different years") {
                let startDate = Date.mockDateFrom(year: 2017, month: 8, day: 4)
                let endDate = startDate + 40.years + 2.months
                try! testCalendarViewModel(startDate: startDate, endDate: endDate)
            }

            it("throws an error if startDate is later than endDate") {
                let startDate = Date.mockDateFrom(year: 2017, month: 8, day: 4)
                let endDate = startDate - 1.day
                try? expect(testCalendarViewModel(startDate: startDate, endDate: endDate)).to(throwError())
                // ...but *not* if it's in the same day
                try! testCalendarViewModel(startDate: endDate + 2.minutes, endDate: endDate)
            }
        }

        describe("date(at:)") {
            var subject: CalendarViewModel!

            context("when it shows leading and trailing days") {
                beforeEach {
                    // Index paths returning dates in section 0: 2 - 32
                    let startDate = Date.mockDateFrom(year: 2017, month: 8, day: 4)
                    let endDate = startDate + 3.days
                    subject = try! CalendarViewModel(startDate: startDate, endDate: endDate,
                                                     showLeadingWeeks: true, showTrailingWeeks: true)
                }
                
                it("returns nil for index paths that fall in the leading or trailing days") {
                    expect(subject.date(at: IndexPath(item: 0, section: 0))).to(beNil())
                    expect(subject.date(at: IndexPath(item: 35, section: 0))).to(beNil())
                }

                it("returns days corresponding to index paths") {
                    expect(subject.date(at: IndexPath(item: 2, section: 0)))
                        .to(equal(Date.mockDateFrom(year: 2017, month: 8, day: 1)))
                    expect(subject.date(at: IndexPath(item: 10, section: 0)))
                        .to(equal(Date.mockDateFrom(year: 2017, month: 8, day: 9)))
                    expect(subject.date(at: IndexPath(item: 32, section: 0)))
                        .to(equal(Date.mockDateFrom(year: 2017, month: 8, day: 31)))
                }
            }

            context("when it shows neither leading nor trailing days") {
                beforeEach {
                    // Index paths returning dates in section 0: 2 - 6
                    let startDate = Date.mockDateFrom(year: 2017, month: 8, day: 4)
                    let endDate = startDate
                    subject = try! CalendarViewModel(startDate: startDate, endDate: endDate,
                                                     showLeadingWeeks: false, showTrailingWeeks: false)
                }

                it("returns nil for index paths that fall in the leading or trailing days") {
                    expect(subject.date(at: IndexPath(item: 1, section: 0))).to(beNil())
                    expect(subject.date(at: IndexPath(item: 7, section: 0))).to(beNil())
                }

                it("returns days corresponding to index paths") {
                    expect(subject.date(at: IndexPath(item: 2, section: 0)))
                        .to(equal(Date.mockDateFrom(year: 2017, month: 8, day: 1)))
                    expect(subject.date(at: IndexPath(item: 10, section: 0))).to(beNil())
                    expect(subject.date(at: IndexPath(item: 32, section: 0))).to(beNil())
                }
            }
        }

        describe("indexPath(from:)") {
            it("") {
                
            }
        }

    }
}
