//
//  SelectedTabCell.swift
//  Tabs-Example
//
//  Created by dandy on 6/11/19.
//  Copyright © 2019 nbaidikoff. All rights reserved.
//

import UIKit
import Tabs

class TabItem: Selectable {
    var betsCount: String
    var isSelected: Bool = false
    
    required init() {
        self.betsCount = ""
    }
    
    init(text: String) {
        self.betsCount = text
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.betsCount)
        hasher.combine(self.isSelected)
    }
    
    static func == (lhs: TabItem, rhs: TabItem) -> Bool {
        return lhs.betsCount == rhs.betsCount && lhs.isSelected == rhs.isSelected
    }
}

class TabView: UIView {
    weak var removalManager: SingleTabViewRemovable?

    private let underlineView = UIView()
    private let textLabel = UILabel()
    private let deleteButton = UIButton()

    init() {
        super.init(frame: .zero)
        self.initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialSetup()
    }
    
    private func initialSetup() {
        self.addSubview(self.underlineView)
        self.addSubview(self.textLabel)
        self.addSubview(self.deleteButton)
        
        self.underlineView.translatesAutoresizingMaskIntoConstraints = false
        self.underlineView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.underlineView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.underlineView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.underlineView.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
        
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0).isActive = true
        
        self.deleteButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8.0).isActive = true
        self.deleteButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.underlineView.backgroundColor = .blue
        self.textLabel.font = .preferredFont(forTextStyle: .caption1)
        self.textLabel.textColor = .white
        self.deleteButton.setTitle("X", for: .normal)
        self.deleteButton.setTitleColor(.white, for: .normal)
        self.deleteButton.addTarget(self, action: #selector(onRemove), for: .touchUpInside)
    }
    
    @objc private func onRemove() {
        self.removalManager?.removeTabItemView(self)
    }
}

extension TabView: SingleTabView {

    typealias Item = TabItem
    
    func setSelected(with item: TabItem) {
        self.textLabel.text = "\(item.betsCount) BETS"
        self.deleteButton.isHidden = false
        self.backgroundColor = UIColor(red: 14.0 / 255.0, green: 16.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)
    }
    
    func setUnselected(with item: TabItem) {
        self.textLabel.text = item.betsCount
        self.deleteButton.isHidden = true
        self.backgroundColor = .black
    }
}
