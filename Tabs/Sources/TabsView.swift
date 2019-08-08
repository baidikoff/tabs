//
//  TabsView.swift
//  Tabs
//
//  Created by dandy on 6/21/19.
//  Copyright © 2019 nbaidikoff. All rights reserved.
//

import Foundation
import UIKit

protocol TabsViewDelegate: SingleTabViewRemovable {
    associatedtype DelegateType: TabsDelegate

    func tabButtonView(_ tabButtonView: TabsView<Self>, didSelectItem item: DelegateType.View.Item, atIndexPath indexPath: IndexPath)
    func tabButtonView(_ tabButtonView: TabsView<Self>, sizeForItem item: DelegateType.View.Item) -> CGSize
    func tabButtonView(_ tabButtonView: TabsView<Self>, willDisplayView view: DelegateType.View, withItem item: DelegateType.View.Item)
}

class TabsView<InnerDelegate: TabsViewDelegate>: UIView {
    typealias View = InnerDelegate.DelegateType.View
    typealias Item = InnerDelegate.DelegateType.View.Item

    private let scrollView = UIScrollView()

    private(set) var items: [Item] = []
    private(set) var views: [View] = []

    private var widthConstraints: [NSLayoutConstraint] = []
    private var leadingConstraints: [NSLayoutConstraint] = []

    private var appearance: TabsAppearance = TabsAppearance()
    private var selectedIndexPath: IndexPath?

    private var selectionIndicator: UIView?
    private var selectionIndicatorWidthConstraint: NSLayoutConstraint?
    private var selectionIndicatorLeadingConstraint: NSLayoutConstraint?

    private unowned let innerDelegate: InnerDelegate

    init(innerDelegate: InnerDelegate) {
        self.innerDelegate = innerDelegate
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func setup(appearance: TabsAppearance) {
        self.appearance = appearance

        self.addConstraints()
        self.configureIndicatorIfNeeded()
        self.configureCollectionView()
    }

    func reload(newItems: [Item]) {
        self.items = newItems
        self.reloadData()
        self.selectFirstItem()
    }

    func updateItems(action: (Item) -> Item) {
        zip(self.items, self.views).enumerated().forEach { arg in
            let (index, item, view) = (arg.offset, arg.element.0, arg.element.1)
            let newItem = action(item)
            self.items[index] = newItem
            self.selectedIndexPath?.row == index ? view.setSelected(with: newItem) : view.setUnselected(with: newItem)
        }
    }

    func insert(newItem: Item) {
        self.items.append(newItem)
        let newView = self.createView(withItem: newItem)

        self.innerDelegate.tabButtonView(self, willDisplayView: newView, withItem: newItem)

        if let lastView = self.views.last {
            self.views.append(newView)
            self.layout(firstView: lastView, secondView: newView, secondItem: newItem)
        } else {
            self.views.append(newView)
            self.layout(view: newView, item: newItem)
        }
    }
    
    func insert(newItem: Item, atIndex index: Int) {
        self.items.insert(newItem, at: index)
        let newView = self.createView(withItem: newItem)
        
        self.innerDelegate.tabButtonView(self, willDisplayView: newView, withItem: newItem)
        
//        if let lastView = self.views.last {
//            self.views.append(newView)
//            self.layout(firstView: lastView, secondView: newView, secondItem: newItem)
//        } else {
//            self.views.append(newView)
//            self.layout(view: newView, item: newItem)
//        }
    }

    func removeItem(atIndexPath indexPath: IndexPath, newSelected: IndexPath) {
        guard self.items.indices.contains(indexPath.row) else { return }

        self.selectedIndexPath = nil
        self.removeItem(at: indexPath)
        self.selectItem(atIndexPath: newSelected)
    }

    func indexPath(forView view: View) -> IndexPath? {
        guard let index = self.views.firstIndex(of: view) else { return nil }
        return IndexPath(row: index, section: 0)
    }

    func selectItem(atIndexPath indexPath: IndexPath) {
        guard self.items.indices.contains(indexPath.row) else { return }

        var animations: [() -> Void] = []
        if let selectedIndex = self.selectedIndexPath, let view = self.view(forItemAt: selectedIndex) {
            self.items[selectedIndex.row].isSelected = false
            animations.append(self.animate(view: view, item: self.items[selectedIndex.row]))
        }

        if let view = self.view(forItemAt: indexPath) {
            self.items[indexPath.row].isSelected = true
            animations.append(self.animate(view: view, item: self.items[indexPath.row]))
        }

        self.selectedIndexPath = indexPath
        self.innerDelegate.tabButtonView(self, didSelectItem: self.items[indexPath.row], atIndexPath: indexPath)

        UIView.animate(withDuration: 0.25) {
            animations.forEach { $0() }
            self.scrollView.layoutIfNeeded()
        }
    }

    func item(for view: View) -> Item? {
        guard let index = self.views.firstIndex(of: view) else { return nil }
        return self.items[index]
    }

    func view(for item: Item) -> View? {
        guard let index = self.items.firstIndex(of: item) else { return nil }
        return self.views[index]
    }

    private func addConstraints() {
        self.addSubview(self.scrollView)

        self.backgroundColor = self.appearance.buttonsBackgroundColor
        self.scrollView.backgroundColor = self.appearance.buttonsBackgroundColor
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.appearance.tabsLeftSpacing).activate()
        self.scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.appearance.tabsRightSpacing).activate()
        self.scrollView.topAnchor.constraint(equalTo: self.topAnchor).activate()
        self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: self.appearance.selectionIndicatorVisible ? -self.appearance.selectionIndicatorHeight : .zero).activate()
    }

    private func configureIndicatorIfNeeded() {
        guard self.appearance.selectionIndicatorVisible else { return }
        let indicator = UIView()
        indicator.backgroundColor = self.appearance.selectionIndicatorColor
        self.addSubview(indicator)

        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.heightAnchor.constraint(equalToConstant: self.appearance.selectionIndicatorHeight).activate()
        indicator.bottomAnchor.constraint(equalTo: self.bottomAnchor).activate()

        self.selectionIndicator = indicator
        self.selectionIndicatorWidthConstraint = indicator.widthAnchor.constraint(equalToConstant: .zero).activated()
        self.selectionIndicatorLeadingConstraint = indicator.leadingAnchor.constraint(equalTo: self.leadingAnchor).activated()
    }

    private func configureCollectionView() {
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
    }

    private func selectFirstItem() {
        self.selectItem(atIndexPath: IndexPath(row: 0, section: 0))
    }

    private func animate(view: View, item: Item) -> () -> Void {
        guard let index = self.views.firstIndex(of: view) else { return {} }

        let newSize = self.innerDelegate.tabButtonView(self, sizeForItem: item)
        let constraint = self.widthConstraints[index]

        return {
            constraint.constant = newSize.width
            item.isSelected ? view.setSelected(with: item) : view.setUnselected(with: item)

            if let indicator = self.selectionIndicator, let widthConstraint = self.selectionIndicatorWidthConstraint, let leadingConstraint = self.selectionIndicatorLeadingConstraint {
                widthConstraint.constant = newSize.width
                leadingConstraint.deactivate()
                self.selectionIndicatorLeadingConstraint = indicator.leadingAnchor.constraint(equalTo: view.leadingAnchor).activated()
            }
        }
    }

    // MARK: -
    // MARK: Scroll view operations

    private func reloadData() {
        self.scrollView.subviews.forEach { $0.removeFromSuperview() }
        self.widthConstraints = []
        self.leadingConstraints = []

        self.views = self.items.map(self.createView)

        if let first = self.views.first, let item = self.items.first {
            self.layout(view: first, item: item)
        }

        zip(self.views, self.views.dropFirst()).forEach { first, second in
            guard let secondItem = self.item(for: second) else { return }
            self.layout(firstView: first, secondView: second, secondItem: secondItem)
        }

        if let last = self.views.last {
            last.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).activate()
        }
    }

    private func removeItem(at indexPath: IndexPath) {
        guard self.items.indices.contains(indexPath.row) else { return }
        self.items.remove(at: indexPath.row)
        self.widthConstraints.remove(at: indexPath.row).isActive = false
        self.leadingConstraints.remove(at: indexPath.row).isActive = false
        let view = self.views.remove(at: indexPath.row)
        view.removeFromSuperview()

        let previousIndex = indexPath.row - 1
        if self.views.indices.contains(indexPath.row) {
            let isNotFirst = self.views.indices.contains(previousIndex)
            let previousAnchor: NSLayoutXAxisAnchor = isNotFirst ? self.views[previousIndex].trailingAnchor : self.scrollView.leadingAnchor
            let nextView = self.views[indexPath.row]

            self.leadingConstraints.remove(at: indexPath.row).isActive = false

            let newLeadingConstraint = nextView.leadingAnchor.constraint(equalTo: previousAnchor, constant: isNotFirst ? self.appearance.tabsInnerSpacing : .zero)
            newLeadingConstraint.activate()
            self.leadingConstraints.insert(newLeadingConstraint, at: indexPath.row)
        }

        UIView.animate(withDuration: 0.25) {
            self.scrollView.layoutIfNeeded()
        }
    }

    private func view(forItemAt indexPath: IndexPath) -> View? {
        guard self.views.indices.contains(indexPath.row) else { return nil }
        return self.views[indexPath.row]
    }

    private func createView(withItem item: Item) -> View {
        let view = View()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.removalManager = self.innerDelegate
        view.configure(with: item)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.selectView(recogniser:))))

        self.innerDelegate.tabButtonView(self, willDisplayView: view, withItem: item)
        self.scrollView.addSubview(view)
        return view
    }

    private func layout(firstView: View, secondView: View, secondItem: Item) {
        let size = self.innerDelegate.tabButtonView(self, sizeForItem: secondItem)

        secondView.heightAnchor.constraint(equalToConstant: size.height).activate()
        secondView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).activate()
        secondView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).activate()

        self.widthConstraints.append(secondView.widthAnchor.constraint(equalToConstant: size.width).activated())
        self.leadingConstraints.append(secondView.leadingAnchor.constraint(equalTo: firstView.trailingAnchor, constant: self.appearance.tabsInnerSpacing).activated())
    }

    private func layout(view: View, item: Item) {
        let size = self.innerDelegate.tabButtonView(self, sizeForItem: item)

        view.heightAnchor.constraint(equalToConstant: size.height).activate()
        view.topAnchor.constraint(equalTo: self.scrollView.topAnchor).activate()
        view.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).activate()

        self.widthConstraints.append(view.widthAnchor.constraint(equalToConstant: size.width).activated())
        self.leadingConstraints.append(view.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).activated())
    }

    @objc private func selectView(recogniser: UITapGestureRecognizer) {
        guard let view = recogniser.view as? View, let index = self.views.firstIndex(of: view) else { return }
        self.selectItem(atIndexPath: IndexPath(row: index, section: 0))
    }
}
