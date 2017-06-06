open class CalendarDayCell: UICollectionViewCell, Dated {
    open var date: Date = Date.distantPast {
        didSet {
            dateLabel.text = String(date.day)
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
        date = Date.distantPast
    }
}
