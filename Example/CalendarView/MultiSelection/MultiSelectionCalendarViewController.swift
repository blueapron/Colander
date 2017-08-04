//
//  MultiSelectionCalendarViewController.swift
//  CalendarView
//
//  Created by Bryan Oltman on 8/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import CalendarView
import SwiftDate
import UIKit

class MultiSelectionCalendarViewController: UIViewController {
    let calendarView = CalendarView()

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Multiple Selection"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        calendarView.register(cellType: SpecializedDayCell.self)
        calendarView.register(supplementaryViewType: SpecializedHeaderView.self, ofKind: UICollectionElementKindSectionHeader)
        calendarView.allowsMultipleSelection = true
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.select(date: Date())
        calendarView.select(date: Date() + 1.week)
        calendarView.select(date: Date() + 2.weeks)
        calendarView.select(date: Date() + 1.month)
        view.addSubview(calendarView)
        calendarView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }
}

extension MultiSelectionCalendarViewController: CalendarViewDataSource {
    var startDate: Date {
        return Date()
    }

    var endDate: Date {
        return Date() + 2.years
    }
}

extension MultiSelectionCalendarViewController: CalendarViewDelegate {
    func calendar(_ calendar: CalendarView, shouldSelectCellAt date: Date) -> Bool {
        return true
    }

    func calendar(_ calendar: CalendarView, didSelectCell cell: UICollectionViewCell, forDate date: Date) {
        print("selected \(date)")
        print("selected dates are now \(calendar.selectedDates)")
    }

    func calendar(_ calendar: CalendarView, didDeselectCell cell: UICollectionViewCell, forDate date: Date) {
        print("deselected \(date)")
        print("selected dates are now \(calendar.selectedDates)")
    }

    func calendar(_ calendar: CalendarView, willDisplayCell cell: UICollectionViewCell, at indexPath: IndexPath, forDate date: Date) {
        guard let dayCell = cell as? SpecializedDayCell else { return }
        dayCell.todayBackground.isHidden = !date.isToday
    }
}
