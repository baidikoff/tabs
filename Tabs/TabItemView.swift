//
//  TabItemView.swift
//  Tabs
//
//  Created by dandy on 6/11/19.
//  Copyright © 2019 nbaidikoff. All rights reserved.
//

import Foundation

public protocol TabItemViewDelegate: class {
    func removeTabItemView<View: TabItemView>(_ view: View)
}

public protocol TabItemView: UIView {
    associatedtype Tab: Selectable
    
    var delegate: TabItemViewDelegate? { get set }
    
    func configure(with item: Tab)
    func setSelected(with item: Tab)
    func setUnselected(with item: Tab)
}

public extension TabItemView {
    func configure(with item: Tab) {
        self.setUnselected(with: item)
    }
}
