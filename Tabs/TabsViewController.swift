//
//  TabsViewController.swift
//  Tabs
//
//  Created by dandy on 6/11/19.
//  Copyright © 2019 nbaidikoff. All rights reserved.
//

import Foundation
import UIKit

public protocol TabsViewDelegate: class {
    associatedtype TabType: Selectable

    func tabsViewController<CellType: TabItemView, Delegate: TabsViewDelegate>(
        _ controller: TabsViewController<TabType, CellType, Delegate>,
        widthForTab tab: TabType
    )
        -> CGFloat
        where CellType.Tab == TabType
}

public class TabsViewController<TabType, CellType: TabItemView, Delegate: TabsViewDelegate>: UIViewController
    where CellType.Tab == TabType, Delegate.TabType == TabType
{
    public var emptyDataPlaceholder: UIView? {
        willSet { self.removeEmptyPlaceholder() }
        didSet { self.setupEmptyPlaceholder() }
    }
 
    private weak var delegate: Delegate?
    
    private let buttonView = TabsButtonView<TabType, TabsViewController, CellType>()
    private lazy var controllersView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private var appearance: TabsAppearance = TabsAppearance()
    private var displayedControllers: [UIViewController] = []
    private(set) var selectedController: UIViewController?
    
    public init(delegate: Delegate, emptyDataPlaceholder: UIView? = nil) {
        self.delegate = delegate
        self.emptyDataPlaceholder = emptyDataPlaceholder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.layoutControllers()
    }

    public func initialSetup(appearance: TabsAppearance = TabsAppearance()) {
        self.appearance = appearance

        self.setup()
        self.buttonView.setup(appearance: appearance)
    }

    public func reload(tabs: [TabType], controllers: [UIViewController]) {
        self.cleanup()

        self.emptyDataPlaceholder?.isHidden = !tabs.isEmpty
        self.buttonView.isHidden = tabs.isEmpty
        self.controllersView.isHidden = tabs.isEmpty
        
        self.buttonView.reload(newItems: tabs)

        self.displayedControllers = controllers
        self.setupControllers()
    }
    
    public func reloadTabs(_ action: (TabType) -> TabType) {
        self.buttonView.updateItems(action: action)
    }
    
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

        self.buttonView.delegate = self
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

extension TabsViewController: TabButtonViewDelegate {
    func tabButtonView<Delegate, CellType>(
        _ tabButtonView: TabsButtonView<TabType, Delegate, CellType>,
        didSelectItem item: TabType,
        atIndexPath indexPath: IndexPath
    )
        where
        Delegate: TabButtonViewDelegate,
        CellType: TabItemView,
        Delegate.TabType == CellType.Tab
    {
        UIView.animate(withDuration: 0.25) {
            self.controllersView.setContentOffset(CGPoint(x: CGFloat(indexPath.row) * self.controllersView.bounds.width, y: .zero), animated: false)
        }
    }

    func tabButtonView<Delegate, CellType>(
        _ tabButtonView: TabsButtonView<TabType, Delegate, CellType>,
        sizeForItem item: TabType
    )
        -> CGSize
        where
        Delegate: TabButtonViewDelegate,
        CellType: TabItemView,
        Delegate.TabType == CellType.Tab
    {
        return CGSize(width: self.delegate?.tabsViewController(self, widthForTab: item) ?? .zero, height: self.appearance.tabsHeight)
    }
}

extension TabsViewController: TabItemViewDelegate {
    public func removeTabItemView<View>(_ view: View) where View: TabItemView {
        guard let itemToRemoveIndexPath = self.buttonView.indexPath(forView: view) else { return }
        
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
    }
}
