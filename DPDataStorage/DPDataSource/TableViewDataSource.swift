//
//  TableViewDataSource.swift
//  DPDataStorage
//
//  Created by Alex on 11/16/17.
//  Copyright © 2017 EffectiveSoft. All rights reserved.
//

import UIKit

protocol TableViewDataSourceDelegate: class {
    func dataSource(_ dataSource: TableViewDataSourceProtocol, cellIdentifierForObject object: Any) -> String
    func dataSource(_ dataSource: TableViewDataSourceProtocol, didSelect object:Any)
}

extension TableViewDataSourceDelegate {
    func dataSource(_ dataSource: TableViewDataSourceProtocol, cellIdentifierForObject object: Any) -> String {
        guard let dataSource = dataSource as? TableViewDataSource<Any>, let cellIdentifier = dataSource.cellIdentifier else {
            fatalError("Could not load")
        }
        return cellIdentifier
    }
}

protocol TableViewDataSourceProtocol {}

class TableViewDataSource<ObjectType>: DataSource<ObjectType>, TableViewDataSourceProtocol, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView?
    @IBInspectable var cellIdentifier: String?
    weak var delegate: TableViewDataSourceDelegate?
    
    init(tableView: UITableView,
         dataSourceContainer: DataSourceContainer<ObjectType>,
         delegate: TableViewDataSourceDelegate?,
         cellIdentifier: String?) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let container = container, let numberOfSections = container.numberOfSections() else {
            return 0
        }
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let container = container, let numberOfItems = container.numberOfItems(in: section) else {
            return 0
        }
        return numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let object = container?.object(at: indexPath) else {
            fatalError("Could not load cell with provided cell identifier")
        }
        var cellIdentifier: String? = nil
        if let delegateCellIdentifier = delegate?.dataSource(self, cellIdentifierForObject: object) {
            cellIdentifier = delegateCellIdentifier
        }
        guard let identifier = cellIdentifier else {
            fatalError("Nor delegate, nor cellIdentifier returns valid value")
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) else {
            fatalError("Could not load cell with provided cell identifier")
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let object = container?.object(at: indexPath) as Any? else {
            fatalError("Object non exists")
        }
        self.delegate?.dataSource(self, didSelect: object)
    }
    
}