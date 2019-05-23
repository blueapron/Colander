import SnapKit
import SwiftDate
import UIKit

public protocol CalendarViewDataSource: class {
    var calendar: Calendar { get }
    var startDate: Date { get }
    var endDate: Date { get }
    var showLeadingWeeks: Bool { get }
    var showTrailingWeeks: Bool { get }
}

public extension CalendarViewDataSource {
    var calendar: Calendar {
        return Calendar.gregorian
    }

    var showLeadingWeeks: Bool {
        return true
    }

    var showTrailingWeeks: Bool {
        return true
    }
}

public protocol CalendarViewDelegate: class {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func calendar(_ calendar: CalendarView, shouldSelectCellAt date: Date) -> Bool
    func calendar(_ calendar: CalendarView, didSelectCell cell: UICollectionViewCell, forDate date: Date)
    func calendar(_ calendar: CalendarView, didDeselectCell cell: UICollectionViewCell, forDate date: Date)
    func calendar(_ calendar: CalendarView, willDisplayCell cell: UICollectionViewCell, at indexPath: IndexPath, forDate date: Date)
}

public extension CalendarViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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

public protocol DateFormatting {
    var dateFormatter: DateFormatter { get }
}

public class CalendarView: UIView {
    public weak var dataSource: CalendarViewDataSource? {
        didSet {
            reloadData()
        }
    }

    public weak var delegate: CalendarViewDelegate?

    var viewModel: CalendarViewModel?

    /// Wraps collectionView.allowsMultipleSelection
    public var allowsMultipleSelection: Bool {
        get {
            return collectionView.allowsMultipleSelection
        }
        set {
            collectionView.allowsMultipleSelection = newValue
        }
    }

    /// The currently selected dates
    public private(set) var selectedDates: [Date] = []

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
        
        let indexPaths = selectedDates.map { viewModel?.indexPath(from: $0) }
        for indexPath in indexPaths {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let width = floor(collectionView.bounds.width / CGFloat(7))
        let insets = (collectionView.bounds.width - (width * 7)) / 2.0

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: insets, bottom: 0, right: insets)
            flowLayout.itemSize = CGSize(width: width, height: 60)
        }
    }

    /**
     Register a `UICollectionViewCell` subclass (conforming to `Dated`) as a UICollectionViewCell.

     - parameter cellType: The `UICollectionViewCell` (`Dated`-conforming) sublcass to register as a date cell.
     */
    public func register<T: UICollectionViewCell>(cellType: T.Type) where T: Dated {
        collectionView.register(cellType, forCellWithReuseIdentifier: "DayCell")
    }

    fileprivate var headerHeight = CGFloat(0)

    /**
     Register a `UICollectionReusableView` subclass (conforming to `Dated`) as a Supplementary View

     - parameter supplementaryViewType: the `UIView` (`Dated`-conforming) subclass to register as Supplementary View
     - parameter elementKind: The kind of supplementary view to create.
     */
    public func register<T: UICollectionReusableView>(supplementaryViewType: T.Type, ofKind elementKind: String) where T: Dated {
        collectionView.register(supplementaryViewType, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: "HeaderView")
        let view = supplementaryViewType.init(frame: CGRect.zero)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        headerHeight = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }

    /**
     Triggers a calendar re-layout; functions similarly to reloadData on UITableView or UICollectionView.
     Call this after changing start/end date or changing the value of showLeadingWeeks or showTrailingWeeks to make
     the calendar view reflect those changes.
     */
    public func reloadData() {
        guard let dataSource = self.dataSource else { return }
        viewModel = try? CalendarViewModel(startDate: dataSource.startDate, endDate: dataSource.endDate,
                                           showLeadingWeeks: dataSource.showLeadingWeeks,
                                           showTrailingWeeks: dataSource.showTrailingWeeks,
                                           calendar: dataSource.calendar)
        collectionView.reloadData()
    }

    /**
     Calls select(date:) on the provided dates.

     - parameter dates: the dates to select
     */
    public func select(dates: [Date]) {
        dates.forEach { select(date: $0) }
    }

    /**
     Selects the cell corresponding the day component provided Date.

     - parameter date: the date to select
     */
    public func select(date: Date) {
        guard !selectedDates.contains(date) else { return }
        selectedDates.append(DateInRegion(date).dateAt(.startOfDay).date)
        collectionView.selectItem(at: viewModel?.indexPath(from: date), animated: false, scrollPosition: [])
    }

    /**
     Deselects the cell corresponding the day component provided Date.

     - parameter date: the date to deselect
     */
    public func deselect(date: Date) {
        let startOfDay = DateInRegion(date).dateAt(.startOfDay).date
        guard let indexPath = viewModel?.indexPath(from: startOfDay) else { return }
        if let index = selectedDates.firstIndex(of: startOfDay) {
            selectedDates.remove(at: index)
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }

    /**
     Selects the cell at the provided index path

     - parameter indexPath: the index path of the cell to select
     */
    public func select(cellAt indexPath: IndexPath) {
        if let date = viewModel?.date(at: indexPath) {
            select(date: date)
        }
    }

    /**
     Deselects the cell at the provided index path

     - parameter indexPath: the index path of the cell to deselect
     */
    public func deselect(cellAt indexPath: IndexPath) {
        if let date = viewModel?.date(at: indexPath) {
            deselect(date: date)
        }
    }

    /**
     Scrolls the calendar to the provided date

     - parameter date:     the date to display
     - parameter position: the position to scroll to (defaults to centeredVertically)
     - parameter animated: whether the scrolling should be animated (defaults to true)
     */
    public func scroll(toDate date: Date, position: UICollectionView.ScrollPosition = .centeredVertically, animated: Bool = true) {
        guard let indexPath = viewModel?.indexPath(from: date) else { return }
        scroll(toIndexPath: indexPath, position: position, animated: animated)
    }

    /**
     Scrolls the calendar to the provided index path

     - parameter indexPath: the index path to scroll to
     - parameter position:  the position to scroll to (defaults to centeredVertically)
     - parameter animated:  whether the scrolling should be animated (defaults to true)
     */
    public func scroll(toIndexPath indexPath: IndexPath, position: UICollectionView.ScrollPosition = .centeredVertically, animated: Bool = true) {
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: animated)
    }
}

extension CalendarView: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.monthInfos.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.dates(in: section).count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let datedCell = cell as? Dated, let date = datedCell.date else { return }
        delegate?.calendar(self, willDisplayCell: cell, at: indexPath, forDate: date)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dayCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath)
        guard var datedCell = dayCell as? Dated else {
            return dayCell
        }

        if let formattingCell = dayCell as? DateFormatting {
            formattingCell.dateFormatter.calendar = viewModel?.calendar
        }

        let date = viewModel?.date(at: indexPath)
        datedCell.date = date
        dayCell.isUserInteractionEnabled = date != nil
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
        if let headerView = headerView as? DateFormatting {
            headerView.dateFormatter.calendar = viewModel?.calendar
        }

        if let currentMonthInfo = viewModel?.monthInfos[indexPath.section], var headerView = headerView as? Dated {
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
            select(date: date)
            delegate?.calendar(self, didSelectCell: cell, forDate: date)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath), let datedCell = cell as? Dated, let date = datedCell.date else { return }
        deselect(date: date)
        delegate?.calendar(self, didDeselectCell: cell, forDate: date)
    }
}
