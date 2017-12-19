//
//  SwiftyViewController.swift
//  SwiftyDPDataStorageExample
//
//  Created by Alex on 12/18/17.
//  Copyright © 2017 Bakhtin. All rights reserved.
//

import UIKit
import DPDataStorage

class SwiftyViewController: UITableViewController, TableViewDataSourceDelegate {
    
    private var dataSource: TableViewDataSource<Employee>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context = DPDataStorage.default().mainContext
        let desciptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchRequest: NSFetchRequest<Employee> = Employee.fetchRequest().sorted(by: desciptors)
        let container = FRCDataSourceContainer(fetchRequest: fetchRequest, context: context, sectionNameKeyPath: nil, delegate: nil)
        dataSource = SwiftyViewControllerDataSource(container: container, delegate: self, tableView: tableView, cellIdentifier: "TableViewCell")
    }
}

class SwiftyViewControllerDataSource<ObjectType>: TableViewDataSource<ObjectType> {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.textColor = UIColor.red
    }

}
