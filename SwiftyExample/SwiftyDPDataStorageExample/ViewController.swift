//
//  ViewController.swift
//  SwiftyDPDataStorageExample
//
//  Created by Alex on 11/16/17.
//  Copyright © 2017 Bakhtin. All rights reserved.
//

import UIKit
import DPDataStorage

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        dataSource.listController = Employee.fetchedResultsController(dataSource, predicate: nil, sortDescriptors: sortDescriptors, in: DPDataStorage.default().mainContext)
    }

    @IBOutlet var dataSource: DPTableViewDataSource!

    // This allows using datasource from swift code
    // @objc(tableView:cellForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "TableViewCell")!
    }

    
}

