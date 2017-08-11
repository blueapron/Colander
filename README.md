# Colander

[![CI Status](http://img.shields.io/travis/Bryan Oltman/CalendarView.svg?style=flat)](https://travis-ci.org/Bryan Oltman/CalendarView)
[![Version](https://img.shields.io/cocoapods/v/CalendarView.svg?style=flat)](http://cocoapods.org/pods/CalendarView)
[![License](https://img.shields.io/cocoapods/l/CalendarView.svg?style=flat)](http://cocoapods.org/pods/CalendarView)
[![Platform](https://img.shields.io/cocoapods/p/CalendarView.svg?style=flat)](http://cocoapods.org/pods/CalendarView)

Colander is a customizable UIView subclass that displays a scrolling calendar view.

## Why "Colander"?
Because Blue Apron is a food company.

Because "Colander" sounds like "calendar". Sort of.

Because "CalendarView" was taken.

## Installation

Colander is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Colander"
```

## Usage

```swift
    // In YourViewController.swift...
    override func viewDidLoad() {
        let calendarView = CalendarView()

        // Optional (but probably something you'll want to do): register cell and header types
        // NOTE: both of these must conform to the Dated protcol, which mandates they have a Date? var with public get and set
        calendarView.register(cellType: YourDayCellClass.self)
        calendarView.register(supplementaryViewType: YourHeaderViewClass.self, ofKind: UICollectionElementKindSectionHeader)

        // Wire up datasource and delegate
        calendarView.dataSource = self
        calendarView.delegate = self
        view.addSubview(calendarView)

        // Assuming you're using SnapKit...
        calendarView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
```

### `CalendarView`
A collection view that displays a calendar. Supported functionality:

- `func select(date: Date)`: Selects the cell corresponding the `day` component provided `Date`.

- `func select(dates: [Date])`: Calls `select(date:)` on the provided dates.

- `func deselect(date: Date)`: Deselects the cell corresponding the `day` component provided `Date`.

- `var selectedDates: [Date]`: A read-only array of all the currently selected dates.

- `func select(cellAt indexPath: IndexPath)`: Selects the cell at the provided index path.

- `func deselect(cellAt indexPath: IndexPath)`: Deselects the cell at the provided index path.

### `CalendarViewDataSource`
There are only two functions required by the data source: `startDate` and `endDate`. These functions represent the range of time displayed by the CalendarView.

`CalendarViewDataSource` also has two optional functions: `showsLeadingWeeks` and `showsTrailingWeeks`.

- `showsLeadingWeeks`: If `true` (the default behavior), the calendar renders every day in `startDate`'s month. If `false`, the earliest date that will be shown is the beginning of `startDate`'s week (i.e., if `startDate` is in the last week of its month and `showsLeadingWeeks` is false, only the week containing `startDate` will be shown).

- `showsTrailingWeeks`: If `true` (the default behavior), the calendar renders every day in `endDate`'s month. If `false`, the last date that will be rendered is the end of `endDate`'s week. (i.e., if `endDate` is in the first week of its month and `showsTrailingWeeks` is false, only the week containing `endDate` will be shown).

### `CalendarViewDelegate`
As with `UITableViewDelegate` and `UICollectionViewDelegate`, adding support for the `CalendarViewDelegate` protocol is entirely optional. These functions simply forward/wrap `UICollectionViewDelegate` functions on the underlying `UICollectionView` and have the same semantics.

## Example

To run the example project:
1. Clone the repo
2. Run `pod install` from the Example directory
3. Open `CalendarView.xcworkspace`, build, and run

The example project contains three different example uses of the CalendarView:
1. Basic: Uses `CalendarDayCell` packaged with ($POD_NAME) and is generally the most minimal use of ($POD_NAME) possible
2. Advanced: Uses a custom day cell and header, highlights the day cell for the current day, supports single selection.
3. Advanceder: Same as Advanced, but with multiple selection. Also demonstrates usage of ($POD_NAME)'s `select(date:)` function.

## Requirements
- iOS 9+
- Xcode 8+

## Dependencies

Colander development was made infinitely more pleasant by [SwiftDate](https://github.com/malcommac/SwiftDate) and [SnapKit](https://github.com/SnapKit/SnapKit).

## Author

Bryan Oltman, bryan.oltman@blueapron.com

## License

Colander is available under the MIT license. See the LICENSE file for more info.