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
    
    public var cellIdentifier: String?
    public weak var delegate: TableViewDataSourceDelegate?
    
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
    
//    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        print("displayed")
//    }
}
