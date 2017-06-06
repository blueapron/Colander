//
//  BasicCalendarViewController.swift
//  CalendarView
//
//  Created by Bryan Oltman on 05/09/2017.
//  Copyright (c) 2017 Bryan Oltman. All rights reserved.
//

import CalendarView
import SnapKit
import SwiftDate
import UIKit

class BasicCalendarViewController: UIViewController {
    let calendarView = CalendarView()

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Basic Calendar View"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        calendarView.register(cellType: CalendarDayCell.self)
        calendarView.register(supplementaryViewType: CalendarMonthHeaderView.self, ofKind: UICollectionElementKindSectionHeader)
        calendarView.dataSource = self
        calendarView.delegate = self
        view.addSubview(calendarView)
        calendarView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension BasicCalendarViewController: CalendarViewDataSource {
    var startDate: Date {
        return Date() - 2.years
    }

    var endDate: Date {
        return Date() + 2.years
    }
}

extension BasicCalendarViewController: CalendarViewDelegate {
}
