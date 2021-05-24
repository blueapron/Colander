//
//  InteractiveDataSourceViewController.swift
//  Colander
//
//  Created by Bryan Oltman on 8/14/17.
//  Copyright © 2017 Blue Apron. All rights reserved.
//

import Colander
import SnapKit
import SwiftDate
import UIKit

class InteractiveDataSourceViewController: UIViewController, CalendarViewDataSource {
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM y"
        return formatter
    }()

    var startDate = Date()
    var endDate = Date() + 2.months
    var showLeadingWeeks: Bool = true
    var showTrailingWeeks: Bool = true

    let calendarView = CalendarView()

    lazy var startDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(picker:)), for: .valueChanged)
        return datePicker
    }()

    lazy var endDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(picker:)), for: .valueChanged)
        return datePicker
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "Configure Datasource"
        self.edgesForExtendedLayout = []
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let configContainerView = UIView()
        configContainerView.backgroundColor = .white
        let configView = createConfigView()
        configContainerView.addSubview(configView)
        configView.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
        }

        view.addSubview(configContainerView)
        configContainerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
        }

        calendarView.register(cellType: SpecializedDayCell.self)
        calendarView.register(supplementaryViewType: SpecializedHeaderView.self, ofKind: UICollectionView.elementKindSectionHeader)
        view.addSubview(calendarView)
        calendarView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(configContainerView.snp.top)
        }
        calendarView.dataSource = self

        updateDatePickers()
    }

    func createConfigView() -> UIView {
        let view = UIView()

        let leadingWeeksLabel = UILabel()
        leadingWeeksLabel.text = "Leading weeks"

        let trailingWeeksLabel = UILabel()
        trailingWeeksLabel.text = "Trailing weeks"

        let leadingWeeksSwitch = UISwitch()
        leadingWeeksSwitch.isOn = self.showLeadingWeeks
        leadingWeeksSwitch.addTarget(self, action: #selector(leadingWeeksToggled(sender:)), for: .valueChanged)

        let trailingWeeksSwitch = UISwitch()
        trailingWeeksSwitch.isOn = self.showTrailingWeeks
        trailingWeeksSwitch.addTarget(self, action: #selector(trailingWeeksToggled(sender:)), for: .valueChanged)

        let toLabel = UILabel()
        toLabel.text = "to"

        view.addSubview(leadingWeeksSwitch)
        view.addSubview(leadingWeeksLabel)
        view.addSubview(trailingWeeksSwitch)
        view.addSubview(trailingWeeksLabel)
        view.addSubview(startDatePicker)
        view.addSubview(toLabel)
        view.addSubview(endDatePicker)

        leadingWeeksLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalTo(leadingWeeksSwitch)
        }

        leadingWeeksSwitch.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(leadingWeeksLabel.snp.right).offset(3)
        }

        trailingWeeksLabel.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(leadingWeeksSwitch.snp.right).offset(20)
            make.right.equalTo(trailingWeeksSwitch.snp.left).offset(-3)
            make.centerY.equalTo(trailingWeeksSwitch)
        }

        trailingWeeksSwitch.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.top.equalToSuperview()
        }

        startDatePicker.snp.makeConstraints { make in
            make.top.equalTo(leadingWeeksSwitch.snp.bottom).offset(20)
            make.left.bottom.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }

        toLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(startDatePicker)
        }

        endDatePicker.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        
        return view
    }

    func updateDatePickers() {
        startDatePicker.date = startDate
        endDatePicker.date = endDate
    }

    @objc func datePickerValueChanged(picker: UIDatePicker) {
        if picker == startDatePicker {
            print("start date picker date is now \(startDatePicker.date)")
            startDate = picker.date
        } else if picker == endDatePicker {
            print("end date picker date is now \(endDatePicker.date)")
            endDate = picker.date
        }
        calendarView.reloadData()
    }

    @objc func leadingWeeksToggled(sender: UISwitch) {
        showLeadingWeeks = sender.isOn
        calendarView.reloadData()
    }

    @objc func trailingWeeksToggled(sender: UISwitch) {
        showTrailingWeeks = sender.isOn
        calendarView.reloadData()
    }
}
