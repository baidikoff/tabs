//
//  Extensions.swift
//  Tabs
//
//  Created by dandy on 6/11/19.
//  Copyright © 2019 nbaidikoff. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    func activate() {
        self.isActive = true
    }
    
    func deactivate() {
        self.isActive = false
    }
    
    func activated() -> NSLayoutConstraint {
        self.activate()
        return self
    }
}
