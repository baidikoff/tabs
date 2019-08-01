//
//  TabsViewDelegate.swift
//  Tabs
//
//  Created by dandy on 6/19/19.
//  Copyright © 2019 nbaidikoff. All rights reserved.
//

import Foundation

public protocol TabsDelegate: class {
    associatedtype View: SingleTabView
    associatedtype ContentController: UIViewController
    
    /// Required
    func tabsViewController(_ controller: TabsViewController<Self>, widthForItem item: View.Item) -> CGFloat
    
    /// Optional
    func tabsViewController(_ controller: TabsViewController<Self>, willDisplayView view: View, withItem item: View.Item)
    
    func tabsViewController(_ controller: TabsViewController<Self>, willRemoveTabWithItem item: View.Item)
    func tabsViewController(_ controller: TabsViewController<Self>, didRemoveTabWithItem item: View.Item)
    
    func tabsViewController(_ controller: TabsViewController<Self>, willShowTabWithItem item: View.Item)
    func tabsViewController(_ controller: TabsViewController<Self>, didShowTabWithItem item: View.Item)
    
    func tabsViewController(_ controller: TabsViewController<Self>, willAppearController viewController: ContentController)
    func tabsViewController(_ controller: TabsViewController<Self>, didAppearController viewController: ContentController)
    
    func tabsViewController(_ controller: TabsViewController<Self>, willDisappearController viewController: ContentController)
    func tabsViewController(_ controller: TabsViewController<Self>, didDisappearController viewController: ContentController)
}

public extension TabsDelegate {
    func tabsViewController(_ controller: TabsViewController<Self>, willDisplayView view: View, withItem item: View.Item) {}
    
    func tabsViewController(_ controller: TabsViewController<Self>, willRemoveTabWithItem item: View.Item) {}
    func tabsViewController(_ controller: TabsViewController<Self>, didRemoveTabWithItem item: View.Item) {}
    
    func tabsViewController(_ controller: TabsViewController<Self>, willShowTabWithItem item: View.Item) {}
    func tabsViewController(_ controller: TabsViewController<Self>, didShowTabWithItem item: View.Item) {}
    
    func tabsViewController(_ controller: TabsViewController<Self>, willAppearController viewController: ContentController) {}
    func tabsViewController(_ controller: TabsViewController<Self>, didAppearController viewController: ContentController) {}
    
    func tabsViewController(_ controller: TabsViewController<Self>, willDisappearController viewController: ContentController) {}
    func tabsViewController(_ controller: TabsViewController<Self>, didDisappearController viewController: ContentController) {}
}
