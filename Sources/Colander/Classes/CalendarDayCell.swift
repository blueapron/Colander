#if canImport(UIKit)

import UIKit

open class CalendarDayCell: UICollectionViewCell, Dated, DateFormatting {
    public let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "d"
        return formatter
    }()

    open var date: Date? {
        didSet {
            guard let date = date else {
                dateLabel.text = ""
                return
            }

            dateLabel.text = dateFormatter.string(from: date)
        }
    }

    let dateLabel = UILabel()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        dateLabel.textColor = .black
        dateLabel.textAlignment = .center
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = ""
        date = nil
    }
}

#endif
