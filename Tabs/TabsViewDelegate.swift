//
//  TabsViewDelegate.swift
//  Tabs
//
//  Created by dandy on 6/19/19.
//  Copyright © 2019 nbaidikoff. All rights reserved.
//

import Foundation

public protocol TabsViewDelegate: class {
    associatedtype TabType: Selectable

    func tabsViewController<CellType: TabItemView, Delegate: TabsViewDelegate>(
        _ controller: TabsViewController<TabType, CellType, Delegate>,
        widthForTab tab: TabType
    )
        -> CGFloat
        where CellType.Tab == TabType

    func tabsViewController<CellType: TabItemView, Delegate: TabsViewDelegate>(
        _ controller: TabsViewController<TabType, CellType, Delegate>,
        willRemoveTabWithItem tab: TabType
    ) where CellType.Tab == TabType

    func tabsViewController<CellType: TabItemView, Delegate: TabsViewDelegate>(
        _ controller: TabsViewController<TabType, CellType, Delegate>,
        didRemoveTabWithItem tab: TabType
    ) where CellType.Tab == TabType
    
    func tabsViewController<CellType: TabItemView, Delegate: TabsViewDelegate>(
        _ controller: TabsViewController<TabType, CellType, Delegate>,
        willShowTabWithItem tab: TabType
    ) where CellType.Tab == TabType
    
    func tabsViewController<CellType: TabItemView, Delegate: TabsViewDelegate>(
        _ controller: TabsViewController<TabType, CellType, Delegate>,
        didShowTabWithItem tab: TabType
    ) where CellType.Tab == TabType
}

extension TabsViewDelegate {
    func tabsViewController<CellType: TabItemView, Delegate: TabsViewDelegate>(
        _ controller: TabsViewController<TabType, CellType, Delegate>,
        willRemoveTabWithItem tab: TabType
    ) where CellType.Tab == TabType {}

    func tabsViewController<CellType: TabItemView, Delegate: TabsViewDelegate>(
        _ controller: TabsViewController<TabType, CellType, Delegate>,
        didRemoveTabWithItem tab: TabType
    ) where CellType.Tab == TabType {}
    
    func tabsViewController<CellType: TabItemView, Delegate: TabsViewDelegate>(
        _ controller: TabsViewController<TabType, CellType, Delegate>,
        willShowTabWithItem tab: TabType
    ) where CellType.Tab == TabType {}
    
    func tabsViewController<CellType: TabItemView, Delegate: TabsViewDelegate>(
        _ controller: TabsViewController<TabType, CellType, Delegate>,
        didShowTabWithItem tab: TabType
    ) where CellType.Tab == TabType {}
}
