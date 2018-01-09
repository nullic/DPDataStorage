//
//  TableViewDataSource.swift
//  DPDataStorage
//
//  Created by Alex on 11/16/17.
//  Copyright © 2017 EffectiveSoft. All rights reserved.
//

import UIKit

public protocol TableViewDataSourceDelegate: class {
    func dataSource(_ dataSource: DataSourceProtocol, cellIdentifierFor object: Any, at indexPath: IndexPath) -> String?
}

public extension TableViewDataSourceDelegate {
    func dataSource(_ dataSource: DataSourceProtocol, cellIdentifierFor object: Any, at indexPath: IndexPath) -> String? {
        return nil
    }
}

open class TableViewDataSource<ObjectType>: NSObject, DataSource, UITableViewDataSource, UITableViewDelegate {

    // MARK: Initializer
    
    public init(container: DataSourceContainer<ObjectType>,
                delegate: TableViewDataSourceDelegate?,
                tableView: UITableView?,
                cellIdentifier: String?) {
        self.container = container
        self.delegate = delegate
        self.tableView = tableView
        self.cellIdentifier = cellIdentifier
        super.init()
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
    }

    // MARK: Public properties
    
    public var container: DataSourceContainer<ObjectType>? {
        didSet {
            tableView?.reloadData()
        }
    }
    
    public var tableView: UITableView? {
        didSet {
            tableView?.dataSource = self
            tableView?.delegate = self
        }
    }
    
    public var cellIdentifier: String? {
        didSet {
            tableView?.reloadData()
        }
    }
    
    public weak var delegate: TableViewDataSourceDelegate?
   
    // MARK: Implementing of datasource methods
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        guard let numberOfSections = numberOfSections else {
            return 0
        }
        return numberOfSections
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfItems = numberOfItems(in: section) else {
            return 0
        }
        return numberOfItems
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let object = object(at: indexPath) else {
            fatalError("Could not retrieve object at \(indexPath)")
        }
        let cellIdentifier = delegate?.dataSource(self, cellIdentifierFor: object, at: indexPath) ?? self.cellIdentifier
        guard let identifier = cellIdentifier else {
            fatalError("Cell identifier is empty")
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) else {
            fatalError("Cell is nil after dequeuring")
        }
        guard let configurableCell = cell as? DataSourceConfigurable else {
            fatalError("Cell is not implementing DataSourceConfigurable protocol")
        }
        configurableCell.configure(with: object)
        return cell
    }

    // MARK: Need to implement all methods here to allow overriding in subclasses
    // In the other way it does not visible to iOS SDK and methods in subclass are not called
    
    // UITableViewDataSource:
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return nil }
    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? { return nil }
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { return false }

    open func sectionIndexTitles(for tableView: UITableView) -> [String]? { return nil }
    open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int { return index }

    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) { }
    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }

    // UITableViewDelegate:
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) { }
    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) { }
    
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    open func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) { }
    open func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) { }
    
    // Variable height support
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return UITableViewAutomaticDimension }
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return UITableViewAutomaticDimension }
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return UITableViewAutomaticDimension }
    
    // NEED to validate automatic dimensions
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { return UITableViewAutomaticDimension }
    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat { return UITableViewAutomaticDimension }
    open func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat { return UITableViewAutomaticDimension }
    
    // Section header & footer information. Views are preferred over title should you decide to provide both
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { return nil }
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { return nil }
    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) { }
    
    
    // Selection
    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { return true }
    open func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) { }
    open func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) { }
    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? { return indexPath }
    open func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? { return indexPath }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) { }
    
    // Editing
    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle { return .delete }
    open func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? { return nil }
    open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? { return nil }
    
    @available(iOS 11.0, *)
    open func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { return nil }
    @available(iOS 11.0, *)
    open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { return nil }
    
    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool { return true }
    open func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) { }
    open func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) { }
    
    
    open func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath
    }
    open func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int { return 0 }
    
    // Copy/Paste.  All three methods must be implemented by the delegate.
    open func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool { return false }
    open func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool { return true }
    open func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {  }
    
    // Focus
    open func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool { return true }
    open func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool { return true }
    open func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) { }
    open func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? { return nil }
   
    // Spring Loading
    @available(iOS 11.0, *)
    open func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        return true
    }
}
