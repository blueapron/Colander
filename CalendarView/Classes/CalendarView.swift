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


// based on https://github.com/mmick66/CalendarView

public class CalendarView: UIView {
    public weak var dataSource: CalendarViewDataSource? {
        didSet {
            guard let dataSource = dataSource else { return }
            viewModel = try? CalendarViewModel(startDate: dataSource.startDate, endDate: dataSource.endDate)
            collectionView.reloadData()
        }
    }

    public weak var delegate: CalendarViewDelegate?

    var viewModel: CalendarViewModel?

    public var allowsMultipleSelection: Bool {
        get {
            return collectionView.allowsMultipleSelection
        }
        set {
            collectionView.allowsMultipleSelection = newValue
        }
    }

    public private(set) var selectedDates: [Date] = []

    public func select(date: Date) {
        selectedDates.append(date)
        collectionView.selectItem(at: viewModel?.indexPath(from: date), animated: false, scrollPosition: [])
    }

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
        
        let indexPaths = selectedDates.map { viewModel?.indexPath(from: $0) }
        for indexPath in indexPaths {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
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
    }

    var headerHeight = CGFloat(0)

    public func register<T: UICollectionReusableView>(supplementaryViewType: T.Type, ofKind elementKind: String) where T: Dated {
        collectionView.register(supplementaryViewType, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: "HeaderView")
        let view = supplementaryViewType.init(frame: CGRect.zero)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        headerHeight = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }

    public func selectCell(at indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
    }
}

extension CalendarView: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.monthInfos.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfItems(in: section) ?? 0
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
            delegate?.calendar(self, didSelectCell: cell, forDate: date)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath), let datedCell = cell as? Dated, let date = datedCell.date else { return }
        delegate?.calendar(self, didDeselectCell: cell, forDate: date)
    }
}
