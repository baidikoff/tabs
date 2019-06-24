//
//  TabsViewController.swift
//  Tabs
//
//  Created by dandy on 6/21/19.
//  Copyright © 2019 nbaidikoff. All rights reserved.
//

import Foundation

public final class TabsViewController<Delegate: TabsDelegate>: UIViewController {
    public typealias View = Delegate.View
    public typealias Item = View.Item

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
    private var displayedControllers: [UIViewController] = []
    private(set) var selectedController: UIViewController?

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

    /// MARK: -
    /// MARK: Public
    public func reload(tabs: [Item], controllers: [UIViewController]) {
        self.cleanup()

        self.emptyDataPlaceholder?.isHidden = !tabs.isEmpty
        self.buttonView.isHidden = tabs.isEmpty
        self.controllersView.isHidden = tabs.isEmpty

        self.buttonView.reload(newItems: tabs)

        self.displayedControllers = controllers
        self.setupControllers()
    }

    public func reloadTabs(_ action: (Item) -> Item) {
        self.buttonView.updateItems(action: action)
    }
    
    public func item(forView view: View) -> Item? {
        return self.buttonView.item(for: view)
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

        self.buttonView.translatesAutoresizingMaskIntoConstraints = false
        self.buttonView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).activate()
        self.buttonView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).activate()
        self.buttonView.topAnchor.constraint(equalTo: self.view.topAnchor).activate()
        self.buttonView.heightAnchor.constraint(equalToConstant: self.appearance.tabsHeight).activate()

        self.controllersView.translatesAutoresizingMaskIntoConstraints = false
        self.controllersView.topAnchor.constraint(equalTo: self.buttonView.bottomAnchor).activate()
        self.controllersView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).activate()
        self.controllersView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).activate()
        self.controllersView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).activate()
    }

    private func cleanup() {
        self.displayedControllers.forEach(self.remove)
    }

    private func remove(controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.removeFromParent()
        controller.view.removeFromSuperview()
    }

    private func setupControllers() {
        self.addControllersToViewHierarcy()
        self.layoutControllers()
    }

    private func addControllersToViewHierarcy() {
        self.displayedControllers.forEach {
            $0.willMove(toParent: self)
            self.addChild($0)
            self.controllersView.addSubview($0.view)
        }
    }

    private func layoutControllers() {
        self.controllersView.contentSize = CGSize(width: CGFloat(self.displayedControllers.count) * self.controllersView.bounds.size.width,
                                                  height: self.view.frame.height - self.buttonView.frame.height)

        self.displayedControllers.enumerated().forEach(self.layoutController)
    }

    private func layoutController(index: Int, controller: UIViewController) {
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
        self.displayedControllers.remove(at: itemToRemoveIndexPath.row)
        self.remove(controller: controller)

        let startingControllerIndexToLayout = itemToRemoveIndexPath.row - 1
        self.displayedControllers.enumerated().forEach { index, controller in
            guard index > startingControllerIndexToLayout else { return }
            self.layoutController(index: index, controller: controller)
        }

        self.delegate.tabsViewController(self, didRemoveTabWithItem: itemToRemove)
    }
}

extension TabsViewController: TabsViewDelegate {
    
    typealias DelegateType = Delegate
    
    func tabButtonView(_ tabButtonView: TabsView<TabsViewController<Delegate>>, didSelectItem item: Item, atIndexPath indexPath: IndexPath) {
        UIView.animate(withDuration: 0.25, animations: {
            self.controllersView.setContentOffset(CGPoint(x: CGFloat(indexPath.row) * self.controllersView.bounds.width, y: .zero), animated: false)
        }, completion: { _ in
            self.delegate.tabsViewController(self, didShowTabWithItem: item)
        })
    }

    func tabButtonView(_ tabButtonView: TabsView<TabsViewController<Delegate>>, sizeForItem item: Item) -> CGSize {
        return CGSize(width: self.delegate.tabsViewController(self, widthForItem: item), height: self.appearance.tabsHeight)
    }

    func tabButtonView(_ tabButtonView: TabsView<TabsViewController<Delegate>>, willDisplayView view: View, withItem item: Item) {
        self.delegate.tabsViewController(self, willDisplayView: view, withItem: item)
    }
}
