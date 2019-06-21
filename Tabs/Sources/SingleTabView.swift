//
//  SingleTabView.swift
//  Tabs
//
//  Created by dandy on 6/21/19.
//  Copyright © 2019 nbaidikoff. All rights reserved.
//

import Foundation
import UIKit

public protocol Selectable: Hashable {
    var isSelected: Bool { get set }
}

public protocol SingleTabViewRemovable: class {    
    func removeTabItemView<View: SingleTabView>(_ view: View)
}

public protocol SingleTabView: UIView {
    associatedtype Item: Selectable
    
    var removalManager: SingleTabViewRemovable? { get set }
    
    func configure(with item: Item)
    func setSelected(with item: Item)
    func setUnselected(with item: Item)
}

public extension SingleTabView {
    func configure(with item: Item) {
        self.setUnselected(with: item)
    }
}
