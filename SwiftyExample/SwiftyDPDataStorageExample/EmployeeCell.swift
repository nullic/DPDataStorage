//
//  EmployeeCell.swift
//  SwiftyDPDataStorageExample
//
//  Created by Alex on 12/18/17.
//  Copyright © 2017 Bakhtin. All rights reserved.
//

import UIKit
import DPDataStorage

class EmployeeCell: UITableViewCell, DPDataSourceCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with object: Any) {
        guard let employee = object as? Employee else {
            return
        }
        self.textLabel?.text = employee.name
    }
}

class SwiftyEmployeeCell: UITableViewCell, DPDataSourceCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with object: Any) {
        guard let employee = object as? Employee else {
            return
        }
        self.textLabel?.text = employee.name
    }
}
