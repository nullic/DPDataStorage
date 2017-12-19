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
    func dataSource(_ dataSource: DataSourceProtocol, didSelect object:Any, at indexPath: IndexPath)
    func dataSource(_ dataSource: DataSourceProtocol, willDispaly cell:DataSourceConfigurable, for object:Any, at indexPath: IndexPath)
}

public extension TableViewDataSourceDelegate {
    func dataSource(_ dataSource: DataSourceProtocol, cellIdentifierFor object: Any, at indexPath: IndexPath) -> String? {
        return nil
    }
    func dataSource(_ dataSource: DataSourceProtocol, didSelect object:Any, at indexPath: IndexPath) { }
    func dataSource(_ dataSource: DataSourceProtocol, willDispaly cell:DataSourceConfigurable, for object:Any, at indexPath: IndexPath) { }
}


public class TableViewDataSource<ObjectType>: NSObject, DataSource, UITableViewDataSource, UITableViewDelegate {
    
    public var container: DataSourceContainer<ObjectType>?
    
    @IBOutlet public weak var tableView: UITableView?
    @IBInspectable public var cellIdentifier: String?
    public weak var delegate: TableViewDataSourceDelegate?
    
    public init(tableView: UITableView,
         container: DataSourceContainer<ObjectType>,
         delegate: TableViewDataSourceDelegate?,
         cellIdentifier: String?) {
        self.tableView = tableView
        self.delegate = delegate
        self.cellIdentifier = cellIdentifier
        self.container = container
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
        var cellIdentifier: String? = nil
        if let delegateCellIdentifier = delegate?.dataSource(self, cellIdentifierFor: object, at: indexPath) {
            cellIdentifier = delegateCellIdentifier
        }
        if cellIdentifier == nil {
            cellIdentifier = self.cellIdentifier
        }
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

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let configurableCell = cell as? DataSourceConfigurable,
            let object = object(at: indexPath) else {
                return
        }
        delegate?.dataSource(self, willDispaly: configurableCell, for: object, at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let object = object(at: indexPath) as Any? else {
            fatalError("Object non exists")
        }
        self.delegate?.dataSource(self, didSelect: object, at: indexPath)
    }
    
}
