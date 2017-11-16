//
//  DataSource.swift
//  DPDataStorage
//
//  Created by Alex on 10/19/17.
//  Copyright © 2017 EffectiveSoft. All rights reserved.
//

import UIKit

protocol DataSourceConfigurable {
    associatedtype ObjectType
    func configure(with object: ObjectType)
}

class DataSource<ObjectType>: NSObject {

    var container: DataSourceContainer<ObjectType>?
    
    var hasData: Bool? {
        get {
            guard let container = container else { return false }
            return container.hasData
        }
    }
    
    var numberOfSections: Int? {
        guard let container = container else { return 0 }
        return container.numberOfSections()
    }

    func numberOfItems(in section: Int) -> Int? {
        return container?.numberOfItems(in: section)
    }

    func object(at indexPath: IndexPath) -> ObjectType? {
        return container?.object(at: indexPath)
    }
    
    func indexPath(for object: ObjectType) -> IndexPath? {
        return container?.indexPath(for: object)
    }
}

