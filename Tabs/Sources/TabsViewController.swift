//
//  TabsViewController.swift
//  Tabs
//
//  Created by dandy on 6/21/19.
//  Copyright © 2019 nbaidikoff. All rights reserved.
//

import Foundation
import UIKit

public final class TabsViewController<Delegate: TabsDelegate>: UIViewController {
    public typealias Controller = Delegate.ContentController
    public typealias View = Delegate.View
    public typealias Item = View.Item

    public var items: [Item] { self.buttonView.items }
    public var viewControllers: [Controller] { self.displayedControllers }

    public var emptyDataPlaceholder: UIView? {
        willSet { self.removeEmptyPlaceholder() }
        didSet { self.setupEmptyPlaceholder() }
    }

    private unowned let delegate: Delegate

    private lazy var buttonView = TabsView(innerDelegate: self)
    private lazy var controllersView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private var appearance: TabsAppearance
    private var displayedControllers: [Controller] = []
    private(set) var selectedController: Controller?

    public init(delegate: Delegate, appearance: TabsAppearance, emptyDataPlaceholder: UIView? = nil) {
        self.delegate = delegate
        self.appearance = appearance
        self.emptyDataPlaceholder = emptyDataPlaceholder
        super.init(nibName: nil, bundle: nil)
        self.setup()
        self.buttonView.setup(appearance: appearance)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.layoutControllers()
    }

    // MARK: -
    // MARK: Public

    /// Reloads
    public func reload(tabs: [Item], controllers: [Controller]) {
        self.cleanup()

        self.emptyDataPlaceholder?.isHidden = !tabs.isEmpty
        self.buttonView.isHidden = tabs.isEmpty
        self.controllersView.isHidden = tabs.isEmpty

        self.displayedControllers = controllers
        self.setupControllers()
        
        self.buttonView.reload(newItems: tabs)
    }

    public func reloadTabs(_ action: (Item) -> Item) {
        self.buttonView.updateItems(action: action)
    }

    /// Accessors
    public func item(forView view: View) -> Item? {
        return self.buttonView.item(for: view)
    }
    
    public func item(forController controller: Controller) -> Item? {
        guard let index = self.displayedControllers.firstIndex(of: controller) else { return nil }
        return self.buttonView.items[index]
    }
    
    public func view(forItem item: Item) -> View? {
        return self.buttonView.view(for: item)
    }
    
    public func view(forController controller: Controller) -> View? {
        guard let index = self.displayedControllers.firstIndex(of: controller) else { return nil }
        return self.buttonView.views[index]
    }
    
    public func controller(forItem item: Item) -> Controller? {
        guard let index = self.buttonView.items.firstIndex(of: item) else { return nil }
        return self.displayedControllers[index]
    }
    
    public func controller(forView view: View) -> Controller? {
        guard let index = self.buttonView.views.firstIndex(of: view) else { return nil }
        return self.displayedControllers[index]
    }
    
    /// Removals
    public func removeTab(withItem item: Item) {
        guard let view = self.buttonView.view(for: item) else { return }
        self.removeTabItemView(view)
    }
    
    public func removeTab(withView view: View) {
        self.removeTabItemView(view)
    }
    
    public func removeTab(withController controller: Controller) {
        guard let index = self.displayedControllers.firstIndex(of: controller) else { return }
        self.removeTabItemView(self.buttonView.views[index])
    }
    
    /// Inserts
    public func insert(tabWithItem item: Item, controller: Controller) {
        let insertionIndex = self.displayedControllers.count
        
        self.delegate.tabsViewController(self, willAppearController: controller)
        self.displayedControllers.append(controller)
        self.add(controller: controller)
        self.layoutController(index: insertionIndex, controller: controller)
        self.delegate.tabsViewController(self, didAppearController: controller)

        self.buttonView.insert(newItem: item)
    }
    
    public func insert(tabWithItem item: Item, controller: Controller, atIndex index: Int) {
        guard index <= self.displayedControllers.count && index >= .zero else { return }
        
        self.delegate.tabsViewController(self, willAppearController: controller)
        self.displayedControllers.insert(controller, at: index)
        self.add(controller: controller)
        self.layoutControllers()
        self.delegate.tabsViewController(self, didAppearController: controller)

        self.buttonView.insert(newItem: item, atIndex: index)
    }

    /// MARK: -
    /// MARK: Private
    private func removeEmptyPlaceholder() {
        guard let placeholder = self.emptyDataPlaceholder else { return }
        placeholder.removeFromSuperview()
    }

    private func setupEmptyPlaceholder() {
        guard let placeholder = self.emptyDataPlaceholder else { return }
        self.view.addSubview(placeholder)
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.isHidden = true
        placeholder.topAnchor.constraint(equalTo: self.view.bottomAnchor).activate()
        placeholder.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).activate()
        placeholder.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).activate()
        placeholder.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).activate()
    }

    private func setup() {
        self.view.addSubview(self.buttonView)
        self.view.addSubview(self.controllersView)

        let fullHeight = self.appearance.tabsHeight + (self.appearance.selectionIndicatorVisible ? self.appearance.selectionIndicatorHeight : .zero)
        self.buttonView.translatesAutoresizingMaskIntoConstraints = false
        self.buttonView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).activate()
        self.buttonView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).activate()
        self.buttonView.topAnchor.constraint(equalTo: self.view.topAnchor).activate()
        self.buttonView.heightAnchor.constraint(equalToConstant: fullHeight).activate()

        self.controllersView.translatesAutoresizingMaskIntoConstraints = false
        self.controllersView.topAnchor.constraint(equalTo: self.buttonView.bottomAnchor).activate()
        self.controllersView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).activate()
        self.controllersView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).activate()
        self.controllersView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).activate()
    }

    private func cleanup() {
        self.displayedControllers.forEach(self.remove)
    }

    private func remove(controller: Controller) {
        controller.viewWillDisappear(true)
        controller.willMove(toParent: nil)
        controller.removeFromParent()
        controller.view.removeFromSuperview()
        controller.viewDidDisappear(true)
    }

    private func setupControllers() {
        self.addControllersToViewHierarcy()
        self.layoutControllers()
    }

    private func addControllersToViewHierarcy() {
        self.displayedControllers.forEach(self.add)
    }
    
    private func add(controller: Controller) {
        controller.willMove(toParent: self)
        controller.view.willMove(toSuperview: self.controllersView)
        
        self.addChild(controller)
        self.controllersView.addSubview(controller.view)
        
        controller.view.didMoveToSuperview()
        controller.didMove(toParent: self)
    }

    private func layoutControllers() {
        self.controllersView.contentSize = CGSize(width: CGFloat(self.displayedControllers.count) * self.controllersView.bounds.size.width,
                                                  height: self.view.frame.height - self.buttonView.frame.height)

        self.displayedControllers.enumerated().forEach(self.layoutController)
    }

    private func layoutController(index: Int, controller: Controller) {
        controller.view.frame = CGRect(x: CGFloat(index) * self.controllersView.bounds.width,
                                       y: .zero,
                                       width: self.controllersView.bounds.width,
                                       height: self.controllersView.bounds.height)
    }
}

extension TabsViewController: SingleTabViewRemovable {
    public func removeTabItemView<View>(_ view: View) where View: SingleTabView {
        guard let view = view as? Delegate.View, let itemToRemoveIndexPath = self.buttonView.indexPath(forView: view) else { return }

        let itemToRemove = self.buttonView.items[itemToRemoveIndexPath.row]
        self.delegate.tabsViewController(self, willRemoveTabWithItem: itemToRemove)

        let newSelectedIndex = IndexPath(row: max(min(itemToRemoveIndexPath.row, self.buttonView.items.count - 2), 0), section: 0)
        self.buttonView.removeItem(atIndexPath: itemToRemoveIndexPath, newSelected: newSelectedIndex)

        let controller = self.displayedControllers[itemToRemoveIndexPath.row]
        self.delegate.tabsViewController(self, willDisappearController: controller)
        self.displayedControllers.remove(at: itemToRemoveIndexPath.row)
        self.remove(controller: controller)
        self.delegate.tabsViewController(self, didDisappearController: controller)
        
        let startingControllerIndexToLayout = itemToRemoveIndexPath.row - 1
        var didSendAppearMessages = false
        self.displayedControllers.enumerated().forEach { index, controller in
            guard index > startingControllerIndexToLayout else { return }
            
            if !didSendAppearMessages {
                self.delegate.tabsViewController(self, willAppearController: controller)
                self.delegate.tabsViewController(self, didAppearController: controller)
                didSendAppearMessages = true
            }
            
            self.layoutController(index: index, controller: controller)
        }

        self.delegate.tabsViewController(self, didRemoveTabWithItem: itemToRemove)
    }
}

extension TabsViewController: TabsViewDelegate {
    typealias DelegateType = Delegate

    func tabButtonView(_ tabButtonView: TabsView<TabsViewController<Delegate>>, didSelectItem item: Item, atIndexPath indexPath: IndexPath) {
        self.animateControllerChange(selectedController: self.selectedController, newSelectedController: self.displayedControllers[indexPath.row], indexPath: indexPath, item: item)
    }

    func tabButtonView(_ tabButtonView: TabsView<TabsViewController<Delegate>>, sizeForItem item: Item) -> CGSize {
        return CGSize(width: self.delegate.tabsViewController(self, widthForItem: item), height: self.appearance.tabsHeight)
    }

    func tabButtonView(_ tabButtonView: TabsView<TabsViewController<Delegate>>, willDisplayView view: View, withItem item: Item) {
        self.delegate.tabsViewController(self, willDisplayView: view, withItem: item)
    }
    
    private func animateControllerChange(selectedController: Controller?, newSelectedController: Controller, indexPath: IndexPath, item: Item) {
        if let selected = selectedController {
            self.delegate.tabsViewController(self, willDisappearController: selected)
        }
        
        self.delegate.tabsViewController(self, willAppearController: newSelectedController)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.controllersView.setContentOffset(CGPoint(x: CGFloat(indexPath.row) * self.controllersView.bounds.width, y: .zero), animated: false)
        }, completion: { _ in
            self.selectedController = newSelectedController
            
            if let selected = selectedController {
                self.delegate.tabsViewController(self, didDisappearController: selected)
            }
            
            self.delegate.tabsViewController(self, didAppearController: newSelectedController)
            self.delegate.tabsViewController(self, didShowTabWithItem: item)
        })
    }
}
