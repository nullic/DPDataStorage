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
    
    private var dataSource: DPTableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context = DPDataStorage.default().mainContext
        let fetchRequest: NSFetchRequest<Employee> = Employee.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = DPTableViewDataSource(tableView: tableView, listController: controller, forwardDelegate: self, cellIdentifier: "TableViewCell")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
