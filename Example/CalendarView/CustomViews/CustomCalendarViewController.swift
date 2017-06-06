//
//  CustomCalendarViewController.swift
//  CalendarView
//
//  Created by Bryan Oltman on 5/16/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import CalendarView
import SwiftDate
import UIKit

class CustomCalendarViewController: UIViewController {
    let calendarView = CalendarView()
    var selectedDate: Date?

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Advanced Calendar View"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        calendarView.register(cellType: SpecializedDayCell.self)
        calendarView.register(supplementaryViewType: SpecializedHeaderView.self, ofKind: UICollectionElementKindSectionHeader)
        calendarView.dataSource = self
        calendarView.delegate = self
        view.addSubview(calendarView)
        calendarView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }
}

extension CustomCalendarViewController: CalendarViewDataSource {
    var startDate: Date {
        return Date()
    }

    var endDate: Date {
        return Date() + 2.years
    }
}

extension CustomCalendarViewController: CalendarViewDelegate {
    func calendar(_ calendar: CalendarView, shouldSelectCellAt date: Date) -> Bool {
        return true
    }

    func calendar(_ calendar: CalendarView, didSelectCell cell: UICollectionViewCell, forDate date: Date) {
    }

    func calendar(_ calendar: CalendarView, didDeselectCell cell: UICollectionViewCell, forDate date: Date) {
    }

    func calendar(_ calendar: CalendarView, willDisplayCell cell: UICollectionViewCell, at indexPath: IndexPath, forDate date: Date) {
        guard let dayCell = cell as? SpecializedDayCell else { return }
        dayCell.todayBackground.isHidden = !date.isToday
    }
}
