//
//  Extensions.swift
//  Tabs
//
//  Created by dandy on 6/11/19.
//  Copyright © 2019 nbaidikoff. All rights reserved.
//

import Foundation

extension NSLayoutConstraint {
    func activate() {
        self.isActive = true
    }
    
    func activated() -> NSLayoutConstraint {
        self.activate()
        return self
    }
}
