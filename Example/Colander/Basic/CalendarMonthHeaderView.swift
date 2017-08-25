import Colander

class CalendarMonthHeaderView: UICollectionReusableView, Dated, DateFormatting {
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    var date: Date? {
        didSet {
            guard let date = date else {
                label.text = ""
                return
            }

            label.text = dateFormatter.string(from: date)
        }
    }

    public let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .clear
        label.textColor = .black
        label.textAlignment = .center
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(44)
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
