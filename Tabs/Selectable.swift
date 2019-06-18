//
//  Selectable.swift
//  Tabs
//
//  Created by dandy on 6/12/19.
//  Copyright © 2019 nbaidikoff. All rights reserved.
//

import Foundation

public protocol Selectable: Hashable {
    init()
    var isSelected: Bool { get set }
}


