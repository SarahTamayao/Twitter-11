# StretchyHeaderViewController
> View controller with a customizable stretchy header in swift.

UIViewController containing a UIScrollView/UITableView/UICollectionView with a stretchy header. The header has a nice parallax effect and the text fades away as the header reaches its minimum size. The header is customizable.

![](StretchyHeader.gif)

## Customizable features
- [x] Header title
- [x] Header subtitle
- [x] Header image
- [x] Minimum header height
- [x] Maximum header height
- [x] Tint color (title and subtitle color)
- [x] Title font
- [x] Text shadow color
- [x] Text shadow offset
- [x] Text shadow radius
- [x] Text shadow opacity
- [x] ScrollView (can be standard UIScrollView, UITableView or UICollectionView)
- [x] Collapsing animation speed
- [x] Expanding animation speed

## Other features
- [x] "progress" variable returns a value between 0 and 1 depending on header progress between its min and max value.
- [x] expandHeader function to expand the header to its maximum height with specified animation speed.
- [x] collapseHeader function to collapse the header to its minimum height with specified animation speed.

## Requirements

- iOS 11.0+
- Xcode 9

## Installation

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `StretchyHeaderViewController` by adding it to your `Podfile`:

```ruby
platform :ios, '11.0'
use_frameworks!
pod 'StretchyHeaderViewController'
```
#### Manually
1. Download and drop ```StretchyHeaderViewController.swift``` in your project.
2. Congratulations!

## Usage example

```swift
let stretchyHeaderViewController = StretchyHeaderViewController()
stretchyHeaderViewController.scrollView = myTableView
stretchyHeaderViewController.headerTitle = myAwesomeTitle
stretchyHeaderViewController.headerSubtitle = myAwesomeSubtitle
stretchyHeaderViewController.minHeaderHeight = 20
stretchyHeaderViewController.maxHeaderHeight = 300
stretchyHeaderViewController.image = myImage
self.present(stretchyHeaderViewController, animated: true, completion: nil)
```
and in the UIScrollView/UITableView/UICollectionView UIScrollViewDelegate :
```swift
func scrollViewDidScroll(_ scrollView: UIScrollView) {
    stretchyHeaderViewController.updateHeaderView()
}
```

## TODO

- Unit testing
- Add option to get header image with an URL
- Any suggestion...

## Meta

Frederic Quenneville
Distributed under the MIT license. See ``LICENSE`` for more information.
