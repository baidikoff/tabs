//
//  ViewController.swift
//  Tabs-Example
//
//  Created by dandy on 6/11/19.
//  Copyright © 2019 nbaidikoff. All rights reserved.
//

import Tabs
import UIKit

extension UIViewController {
    convenience init(color: UIColor) {
        self.init()
        self.view.backgroundColor = color
    }
}

class ViewController: UIViewController {
    let appearance = TabsAppearance()
    private let tabsViewController = TabsViewController<TabItem, TabView, ViewController>()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.appearance.buttonsBackgroundColor = .black
        
        self.tabsViewController.delegate = self
        self.addChild(self.tabsViewController)
        self.view.addSubview(self.tabsViewController.view)

        self.view.backgroundColor = .black
        self.tabsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.tabsViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tabsViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.tabsViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 36.0).isActive = true
        self.tabsViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        self.tabsViewController.initialSetup(appearance: self.appearance)

        let tabs = [TabItem(text: "1"), TabItem(text: "2"), TabItem(text: "3"), TabItem(text: "15"), TabItem(text: "20"), TabItem(text: "21"), TabItem(text: "11"), TabItem(text: "23")]
        let controllers = [UIViewController(color: .red), UIViewController(color: .blue), UIViewController(color: .brown), UIViewController(color: .green), UIViewController(color: .red), UIViewController(color: .blue), UIViewController(color: .brown), UIViewController(color: .green)]
        self.tabsViewController.reload(tabs: tabs, controllers: controllers)
    }
}

extension ViewController: TabsViewDelegate {
    typealias TabType = TabItem

    func tabsViewController<CellType, Delegate>(
        _ controller: TabsViewController<TabItem, CellType, Delegate>,
        widthForTab tab: TabItem
    )
        -> CGFloat
        where
        CellType: TabItemView,
        Delegate: TabsViewDelegate,
        CellType.Tab == Delegate.TabType
    {
        let string = tab.isSelected ? "\(tab.betsCount) BETS" : tab.betsCount
        let text = NSAttributedString(string: string, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1)])
        let textWidth = text.boundingRect(with: CGSize(width: CGFloat.infinity, height: .infinity), options: [], context: nil).width

        let width: CGFloat = tab.isSelected ? textWidth + 106.0 : textWidth + 16.0
        return ceil(width)
    }
}
