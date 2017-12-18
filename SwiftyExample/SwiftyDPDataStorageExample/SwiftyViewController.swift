//
//  SwiftyViewController.swift
//  SwiftyDPDataStorageExample
//
//  Created by Alex on 12/18/17.
//  Copyright © 2017 Bakhtin. All rights reserved.
//

import UIKit
import DPDataStorage

class SwiftyViewController: UITableViewController {
    
    private var dataSource: TableViewDataSource<Employee>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context = DPDataStorage.default().mainContext
        let desciptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchRequest: NSFetchRequest<Employee> = Employee.fetchRequest().sorted(by: desciptors)
        let container = FRCDataSourceContainer(fetchRequest: fetchRequest, context: context, sectionNameKeyPath: nil, delegate: nil)
        dataSource = TableViewDataSource(tableView: tableView, dataSourceContainer: container, delegate: self, cellIdentifier: "TableViewCell")
    }
}

extension SwiftyViewController: TableViewDataSourceDelegate {
    
    func dataSource(_ dataSource: TableViewDataSourceProtocol, willDispaly cell: DataSourceConfigurable, for object: Any, at indexPath: IndexPath) {
        guard let cell = cell as? SwiftyEmployeeCell else {
            return
        }
        cell.textLabel?.textColor = UIColor.red
    }
    
}
