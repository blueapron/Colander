import SnapKit
import SwiftDate
import UIKit

public protocol CalendarViewDataSource: class {
    var startDate: Date { get }
    var endDate: Date { get }
    var showsLeadingWeeks: Bool { get }
    var showsTrailingWeeks: Bool { get }
}

public extension CalendarViewDataSource {
    var showsLeadingWeeks: Bool {
        return true
    }

    var showsTrailingWeeks: Bool {
        return true
    }
}

public protocol Dated {
    var date: Date? { get set }
}

public protocol CalendarViewDelegate: class {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func calendar(_ calendar: CalendarView, cell: UICollectionViewCell, at indexPath: IndexPath, forDate date: Date)
    func calendar(_ calendar: CalendarView, shouldSelectCellAt date: Date) -> Bool
    func calendar(_ calendar: CalendarView, didSelectCell cell: UICollectionViewCell, forDate date: Date)
    func calendar(_ calendar: CalendarView, didDeselectCell cell: UICollectionViewCell, forDate date: Date)
    func calendar(_ calendar: CalendarView, willDisplayCell cell: UICollectionViewCell, at indexPath: IndexPath, forDate date: Date)
}

public extension CalendarViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }

    func calendar(_ calendar: CalendarView, cell: UICollectionViewCell, at indexPath: IndexPath, forDate date: Date) {
    }

    func calendar(_ calendar: CalendarView, shouldSelectCellAt date: Date) -> Bool {
        return true
    }

    func calendar(_ calendar: CalendarView, didSelectCell cell: UICollectionViewCell, forDate date: Date) {
    }

    func calendar(_ calendar: CalendarView, didDeselectCell cell: UICollectionViewCell, forDate date: Date) {
    }

    func calendar(_ calendar: CalendarView, willDisplayCell cell: UICollectionViewCell, at indexPath: IndexPath, forDate date: Date) {
    }
}

fileprivate struct MonthInfo {
    let startDate: Date
    let firstDayWeekdayIndex: Int
    let numberOfDaysInMonth: Int

    init?(startDate: Date) {
        guard let numberOfDaysInMonth = Calendar.gregorian.range(of: .day, in: .month, for: startDate)?.count else {
            return nil
        }

        self.startDate = startDate
        self.firstDayWeekdayIndex = Calendar.gregorian.component(.weekday, from: startDate) - 1 // 1-indexed to 0-indexed
        self.numberOfDaysInMonth = numberOfDaysInMonth
    }

    func contains(index: Int) -> Bool {
        let range = firstDayWeekdayIndex..<(firstDayWeekdayIndex + numberOfDaysInMonth)
        return range.contains(index)
    }
}

// based on https://github.com/mmick66/CalendarView

public class CalendarView: UIView {
    public weak var dataSource: CalendarViewDataSource? {
        didSet {
            guard let dataSource = dataSource else { return }
            startDate = dataSource.startDate
            endDate = dataSource.endDate
            collectionView.reloadData()
        }
    }

    public weak var delegate: CalendarViewDelegate?
    var highlightCurrentDate: Bool = true
    var allowMultipleSelection: Bool = false

    fileprivate let daysPerWeek = Calendar.gregorian.weekdaySymbols.count
    fileprivate var startDate = Date()
    fileprivate var endDate = Date()
    fileprivate var monthInfos: [Int: MonthInfo] = [:]

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsMultipleSelection = false

        return collectionView
    }()

    var width: CGFloat = 0
    var insets: CGFloat = 0

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.createSubviews()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.createSubviews()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.createSubviews()
    }

    private func createSubviews() {
        clipsToBounds = true
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        setNeedsLayout()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        width = floor(collectionView.bounds.width / CGFloat(7))
        insets = (collectionView.bounds.width - (width * 7)) / 2.0

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: insets, bottom: 0, right: insets)
            flowLayout.itemSize = CGSize(width: width, height: 60)
        }
    }

    public func register<T: UICollectionViewCell>(cellType: T.Type) where T: Dated {
        collectionView.register(cellType, forCellWithReuseIdentifier: "DayCell")
        // collectionView.register(cellType: cellType, wi)
    }

    var headerHeight = CGFloat(0)

    public func register<T: UICollectionReusableView>(supplementaryViewType: T.Type, ofKind elementKind: String) where T: Dated {
        collectionView.register(supplementaryViewType, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: "HeaderView")
        let view = supplementaryViewType.init(frame: CGRect.zero)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        headerHeight = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }
}

extension CalendarView: UICollectionViewDataSource {
    func firstDisplayDate(from startDate: Date, showLeadingDays: Bool) -> Date {
        // EffectiveStartDate is the beginning of the week including startDate
        if showLeadingDays {
            return startDate.beginningOfMonth ?? Date()
        } else {
            return startDate - (startDate.weekday - 1).days
        }
    }

    func numberOfSections(startDate: Date, endDate: Date) -> Int {
        let monthSpan = endDate.month - startDate.month
        let yearSpan = endDate.year - startDate.year
        return yearSpan * 12 + monthSpan + 1
    }

    func numberOfItems(in section: Int) -> Int {
        guard let monthStartDate = startDate.beginningOfMonth, let monthInfo = MonthInfo(startDate: monthStartDate + section.months) else {
            return 0
        }

        monthInfos[section] = monthInfo
        var numberOfDays = monthInfo.numberOfDaysInMonth
        var offset = monthInfo.firstDayWeekdayIndex
        let sectionCount = numberOfSections(startDate: startDate, endDate: endDate)
        let effectiveStartDate = firstDisplayDate(from: startDate, showLeadingDays: dataSource?.showsLeadingWeeks == true)
        // If we're in our first month, don't show weeks leading up to but not including startDate
        if dataSource?.showsLeadingWeeks == false && startDate.isSameMonthAs(effectiveStartDate) && section == 0 {
            numberOfDays -= effectiveStartDate.day
            offset = 1
        }

        if dataSource?.showsTrailingWeeks == false && section == sectionCount - 1 {
            let daysAfterEndDate = daysPerWeek - endDate.weekday
            numberOfDays = endDate.day + daysAfterEndDate
        }

        let requiredRows = ceil((Double(numberOfDays) + Double(offset)) / Double(daysPerWeek))

        // We display full rows for every week we display, even if the current month starts or ends before the week.
        return Int(requiredRows) * daysPerWeek
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard dataSource != nil else { return 0 }

        // Check if the dates are in correct order
        guard startDate < endDate else { return 0 }

        return numberOfSections(startDate: startDate, endDate: endDate)
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems(in: section)
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let datedCell = cell as? Dated, let date = datedCell.date else { return }
        delegate?.calendar(self, willDisplayCell: cell, at: indexPath, forDate: date)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dayCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath)
        guard let currentMonthInfo = monthInfos[indexPath.section] else {
            return dayCell
        }

        var offset = currentMonthInfo.firstDayWeekdayIndex
        var item = indexPath.item
        var inCurrentMonth = false
        let effectiveStartDate = firstDisplayDate(from: startDate, showLeadingDays: dataSource?.showsLeadingWeeks == true)

        // if we're in our first month, don't show weeks leading up to but not including startDate
        if dataSource?.showsLeadingWeeks == false && startDate.isSameMonthAs(effectiveStartDate) && indexPath.section == 0 {
            item += effectiveStartDate.day - 1
            offset = 0
            inCurrentMonth = item < currentMonthInfo.numberOfDaysInMonth
        } else {
            inCurrentMonth = currentMonthInfo.contains(index: item)
        }

        guard inCurrentMonth else {
            dayCell.isHidden = true
            return dayCell
        }

        dayCell.isHidden = false
        let cellDate = currentMonthInfo.startDate + (item - offset).days
        if var datedCell = dayCell as? Dated {
            datedCell.date = cellDate
        }

        if highlightCurrentDate {
            // dayCell.state = dayCell.date.isToday ? .selected : .base
        }

        delegate?.calendar(self, cell: dayCell, at: indexPath, forDate: cellDate)

        return dayCell
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: headerHeight)
    }

    public func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath)
        if let currentMonthInfo = monthInfos[indexPath.section], var headerView = headerView as? Dated {
            headerView.date = currentMonthInfo.startDate
        }

        return headerView
    }
}

extension CalendarView: UICollectionViewDelegateFlowLayout {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
    }

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let delegate = delegate,
            let cell = collectionView.cellForItem(at: indexPath),
            let datedCell = cell as? Dated,
            let date = datedCell.date else { return false }
        return delegate.calendar(self, shouldSelectCellAt: date)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        if let datedCell = cell as? Dated, let date = datedCell.date {
            delegate?.calendar(self, didSelectCell: cell, forDate: date)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath), let datedCell = cell as? Dated, let date = datedCell.date else { return }
        delegate?.calendar(self, didDeselectCell: cell, forDate: date)
    }
}
