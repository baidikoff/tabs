//
//  ViewController.swift
//  Tabs-Example
//
//  Created by dandy on 6/11/19.
//  Copyright © 2019 nbaidikoff. All rights reserved.
//

import Tabs
import UIKit

class Controller: UIViewController {
    convenience init(color: UIColor) {
        self.init()
        self.view.backgroundColor = color
    }
}

final class ViewController: UIViewController {
    let appearance: TabsAppearance = {
        let appearance = TabsAppearance()
        appearance.buttonsBackgroundColor = .black
        return appearance
    }()
    
    private lazy var tabsViewController = TabsViewController<ViewController>(delegate: self, appearance: self.appearance)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.appearance.buttonsBackgroundColor = .black

        self.addChild(self.tabsViewController)
        self.view.addSubview(self.tabsViewController.view)

        self.view.backgroundColor = .black
        self.tabsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.tabsViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tabsViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.tabsViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 36.0).isActive = true
        self.tabsViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        let tabs = [TabItem(text: "1")]
        let controllers = [Controller(color: .red)]
        self.tabsViewController.reload(tabs: tabs, controllers: controllers)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.tabsViewController.insert(tabWithItem: TabItem(text: "2"), controller: Controller(color: .green))
        }
    }
}

extension ViewController: TabsDelegate {
    typealias View = TabView
    typealias ContentController = Controller

    func tabsViewController(_ controller: TabsViewController<ViewController>, widthForItem item: TabItem) -> CGFloat {
        let string = item.isSelected ? "\(item.betsCount) BETS" : item.betsCount
        let text = NSAttributedString(string: string, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1)])
        let textWidth = text.boundingRect(with: CGSize(width: CGFloat.infinity, height: .infinity), options: [], context: nil).width

        let width: CGFloat = item.isSelected ? textWidth + 106.0 : textWidth + 16.0
        return ceil(width)
    }
    
    func tabsViewController(_ controller: TabsViewController<ViewController>, willAppearController viewController: Controller) {
        print("will appear")
    }
    
    func tabsViewController(_ controller: TabsViewController<ViewController>, didAppearController viewController: Controller) {
        print("did appear")
    }
    
    func tabsViewController(_ controller: TabsViewController<ViewController>, willDisappearController viewController: Controller) {
        print("will disappear")
    }
    
    func tabsViewController(_ controller: TabsViewController<ViewController>, didDisappearController viewController: Controller) {
        print("did disappear")
    }
}
