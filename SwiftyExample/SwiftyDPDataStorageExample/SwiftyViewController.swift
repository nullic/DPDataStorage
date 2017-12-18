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
        let fetchRequest: NSFetchRequest<Employee> = Employee.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let container = CoreDataDataSourceContainer(fetchRequest: fetchRequest, context: context, sectionNameKeyPath: nil, delegate: nil)
        dataSource = TableViewDataSource(tableView: tableView, dataSourceContainer: container, delegate: self, cellIdentifier: "TableViewCell")
    }

}

extension SwiftyViewController: TableViewDataSourceDelegate {
    func dataSource(_ dataSource: TableViewDataSourceProtocol, didSelect object: Any) {
        
    }
}
