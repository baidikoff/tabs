//
//  TabsButtonView.swift
//  Tabs
//
//  Created by dandy on 6/11/19.
//  Copyright © 2019 nbaidikoff. All rights reserved.
//

import Foundation

protocol TabButtonViewDelegate: class {
    associatedtype TabType: Selectable

    func tabButtonView<Delegate, CellType>(
        _ tabButtonView: TabsButtonView<TabType, Delegate, CellType>,
        didSelectItem item: TabType,
        atIndexPath indexPath: IndexPath
    )
        where
        Delegate: TabButtonViewDelegate,
        CellType: TabItemView,
        Delegate.TabType == CellType.Tab

    func tabButtonView<Delegate, CellType>(
        _ tabButtonView: TabsButtonView<TabType, Delegate, CellType>,
        sizeForItem item: TabType
    )
        -> CGSize
        where
        Delegate: TabButtonViewDelegate,
        CellType: TabItemView,
        Delegate.TabType == CellType.Tab
}

class TabsButtonView<TabType, DelegateType: TabButtonViewDelegate, CellType: TabItemView>: UIView
    where DelegateType: TabItemViewDelegate,
    DelegateType.TabType == TabType,
    CellType.Tab == TabType
{
    @objc private let scrollView = UIScrollView()
    private(set) var items: [TabType] = []
    private var views: [CellType] = []
    private var widthConstraints: [NSLayoutConstraint] = []
    private var leadingConstraints: [NSLayoutConstraint] = []

    private var appearance: TabsAppearance = TabsAppearance()
    private var selectedIndexPath: IndexPath?

    weak var delegate: DelegateType?

    func setup(appearance: TabsAppearance) {
        self.appearance = appearance

        self.addConstraints()
        self.configureCollectionView()
    }

    func reload(newItems: [TabType]) {
        self.items = newItems
        self.reloadData()
        self.selectFirstItem()
    }
    
    func updateItems(action: (TabType) -> TabType) {
        zip(self.items, self.views).enumerated().forEach { arg in
            let (index, item, view) = (arg.offset, arg.element.0, arg.element.1)
            let newItem = action(item)
            self.items[index] = newItem
            self.selectedIndexPath?.row == index ? view.setSelected(with: newItem) : view.setUnselected(with: newItem)
        }
    }

    func removeItem(atIndexPath indexPath: IndexPath, newSelected: IndexPath) {
        guard self.items.indices.contains(indexPath.row) else { return }

        self.selectedIndexPath = nil
        self.removeItem(at: indexPath)
        self.selectItem(atIndexPath: newSelected)
    }

    func indexPath<View: TabItemView>(forView view: View) -> IndexPath? {
        guard let cell = view as? CellType, let index = self.views.firstIndex(of: cell) else { return nil }
        return IndexPath(row: index, section: 0)
    }

    func selectItem(atIndexPath indexPath: IndexPath) {
        guard self.items.indices.contains(indexPath.row) else { return }

        var animations: [() -> Void] = []
        if let selectedIndex = self.selectedIndexPath, let cell = self.cell(forItemAt: selectedIndex) {
            self.items[selectedIndex.row].isSelected = false
            animations.append(self.animate(cell: cell, item: self.items[selectedIndex.row]))
        }

        if let cell = self.cell(forItemAt: indexPath) {
            self.items[indexPath.row].isSelected = true
            animations.append(self.animate(cell: cell, item: self.items[indexPath.row]))
        }

        self.selectedIndexPath = indexPath
        self.delegate?.tabButtonView(self, didSelectItem: self.items[indexPath.row], atIndexPath: indexPath)

        UIView.animate(withDuration: 0.25) {
            animations.forEach { $0() }
            self.scrollView.layoutIfNeeded()
        }
    }

    private func addConstraints() {
        self.addSubview(self.scrollView)

        self.backgroundColor = self.appearance.buttonsBackgroundColor
        self.scrollView.backgroundColor = self.appearance.buttonsBackgroundColor
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.appearance.tabsLeftSpacing).activate()
        self.scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.appearance.tabsRightSpacing).activate()
        self.scrollView.topAnchor.constraint(equalTo: self.topAnchor).activate()
        self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).activate()
    }

    private func configureCollectionView() {
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
    }

    private func selectFirstItem() {
        self.selectItem(atIndexPath: IndexPath(row: 0, section: 0))
    }

    private func animate(cell: CellType, item: TabType) -> () -> Void {
        guard let index = self.views.firstIndex(of: cell) else { return {} }

        let newSize = self.delegate?.tabButtonView(self, sizeForItem: item) ?? .zero
        let constraint = self.widthConstraints[index]

        return {
            constraint.constant = newSize.width
            item.isSelected ? cell.setSelected(with: item) : cell.setUnselected(with: item)
        }
    }

    /// MARK: -
    /// MARK: Scroll view operations
    private func reloadData() {
        self.scrollView.subviews.forEach { $0.removeFromSuperview() }
        self.widthConstraints = []
        self.leadingConstraints = []

        self.views = self.items.map {
            let view = CellType()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.delegate = self.delegate
            view.configure(with: $0)
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectView(recogniser:))))
            self.scrollView.addSubview(view)
            return view
        }

        if let first = self.views.first, let item = self.items.first, let size = self.delegate?.tabButtonView(self, sizeForItem: item) {
            let leadingConstraint = first.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor)
            leadingConstraint.activate()
            let widthConstraint = first.widthAnchor.constraint(equalToConstant: size.width)
            widthConstraint.activate()
            first.heightAnchor.constraint(equalToConstant: size.height).activate()
            first.topAnchor.constraint(equalTo: self.scrollView.topAnchor).activate()
            first.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).activate()

            self.widthConstraints.append(widthConstraint)
            self.leadingConstraints.append(leadingConstraint)
        }

        zip(self.views, self.views.dropFirst()).forEach { first, second in
            guard let secondItem = self.item(for: second), let secondSize = self.delegate?.tabButtonView(self, sizeForItem: secondItem) else { return }
            let leadingConstraint = second.leadingAnchor.constraint(equalTo: first.trailingAnchor, constant: self.appearance.tabsInnerSpacing)
            leadingConstraint.activate()
            let widthConstraint = second.widthAnchor.constraint(equalToConstant: secondSize.width)
            widthConstraint.activate()
            second.heightAnchor.constraint(equalToConstant: secondSize.height).activate()
            second.topAnchor.constraint(equalTo: self.scrollView.topAnchor).activate()
            second.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).activate()

            self.widthConstraints.append(widthConstraint)
            self.leadingConstraints.append(leadingConstraint)
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

    private func item(for cell: CellType) -> TabType? {
        guard let index = self.views.firstIndex(of: cell) else { return nil }
        return self.items[index]
    }

    private func cell(forItemAt indexPath: IndexPath) -> CellType? {
        guard self.views.indices.contains(indexPath.row) else { return nil }
        return self.views[indexPath.row]
    }

    private func cell(for item: TabType) -> CellType? {
        guard let index = self.items.firstIndex(of: item), self.views.indices.contains(index) else { return nil }
        return self.views[index]
    }

    @objc private func selectView(recogniser: UITapGestureRecognizer) {
        guard let view = recogniser.view as? CellType, let index = self.views.firstIndex(of: view) else { return }
        self.selectItem(atIndexPath: IndexPath(row: index, section: 0))
    }
}
