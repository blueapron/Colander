//
//  SpecializedDayCell.swift
//  CalendarView
//
//  Created by Bryan Oltman on 5/16/17.
//  Copyright © 2017 Blue Apron. All rights reserved.
//

import Colander

class SpecializedDayCell: UICollectionViewCell, Dated, DateFormatting {
    public let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "d"
        return formatter
    }()

    var date: Date? {
        didSet {
            guard let date = date else {
                dateLabel.text = ""
                return
            }

            dateLabel.text = dateFormatter.string(from: date)
        }
    }

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor.darkGray.withAlphaComponent(0.3) : .clear
        }
    }

    let dateLabel = UILabel()
    let todayBackground = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(todayBackground)
        contentView.addSubview(dateLabel)

        todayBackground.backgroundColor = UIColor.blue.withAlphaComponent(0.3)
        todayBackground.layer.cornerRadius = 8
        todayBackground.isHidden = true
        todayBackground.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(7)
        }

        dateLabel.textAlignment = .center
        dateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = ""
        todayBackground.isHidden = true
    }
}
