//
//  SpecializedHeaderView.swift
//  CalendarView
//
//  Created by Bryan Oltman on 5/16/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import CalendarView
import SnapKit
import UIKit

class SpecializedHeaderView: UICollectionReusableView, Dated {
    var date: Date = Date.distantPast {
        didSet {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(secondsFromGMT: 0)

            formatter.dateFormat = "MMMM"
            monthLabel.text = formatter.string(from: date)

            formatter.dateFormat = "yyyy"
            yearLabel.text = formatter.string(from: date)
        }
    }

    let monthLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        // label.textStyle = TextStyle(font: .ceraMediumFont(ofSize: 15), color: .mainBlue)
        return label
    }()

    let yearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        // label.textStyle = TextStyle(font: .chronicleBookFont(ofSize: 14), color: .accentBlue)
        return label
    }()

    var showsDateLabels = true {
        didSet {
            weekdayHeightConstraint?.update(offset: showsDateLabels ? 27 : 0)
            dateLabelContainer.isHidden = !showsDateLabels
        }
    }

    let dateLabelContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        return stackView
    }()

    private var weekdayHeightConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .lightGray

        let containerView = UIView()
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.height.equalTo(44)
        }

        containerView.addSubview(monthLabel)
        containerView.addSubview(yearLabel)
        monthLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }

        yearLabel.snp.makeConstraints { make in
            make.leading.equalTo(monthLabel.snp.trailing).offset(3)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(monthLabel)
        }

        addSubview(dateLabelContainer)
        dateLabelContainer.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom)
            make.bottom.equalToSuperview().inset(5)
            make.left.right.equalToSuperview().inset(3)
            weekdayHeightConstraint = make.height.equalTo(26).constraint
        }

        // dateLabelContainer.addBorder(edges: [.top], color: UIColor(white: 0, alpha: 0.08))
        // addBorder(edges: [.bottom], color: UIColor(white: 0, alpha: 0.08))

        let formatter = DateFormatter()
        for index in 0...6 {
            let day = formatter.weekdaySymbols[index % 7]
            let weekdayLabel = UILabel()
            weekdayLabel.textAlignment = .center
            // weekdayLabel.textStyle = TextStyle(font: .ceraRegularFont(ofSize: 10), color: .accentBlue, alignment: .center)
            weekdayLabel.text = String(day.characters.first ?? Character(""))

            let labelContainer = UIView()
            labelContainer.addSubview(weekdayLabel)
            weekdayLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            dateLabelContainer.addArrangedSubview(labelContainer)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
