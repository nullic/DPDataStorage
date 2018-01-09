//
//  DataSource.swift
//  DPDataStorage
//
//  Created by Alex on 10/19/17.
//  Copyright © 2017 EffectiveSoft. All rights reserved.
//

import UIKit

public protocol DataSourceConfigurable {
    func configure(with object: Any)
}

public protocol DataSourceProtocol {
}

public protocol DataSource: DataSourceProtocol {
    associatedtype ObjectType
    
    var container: DataSourceContainer<ObjectType>? { get set }
    var hasData: Bool? { get }
    var numberOfSections: Int? { get }
    func numberOfItems(in section: Int) -> Int?
    func object(at indexPath: IndexPath) -> ObjectType?
    func indexPath(for object: ObjectType) -> IndexPath?
}

extension DataSource {
    
    public var hasData: Bool? {
        return container?.hasData
    }
    
    public var numberOfSections: Int? {
        return container?.numberOfSections()
    }
    
    public func numberOfItems(in section: Int) -> Int? {
        return container?.numberOfItems(in: section)
    }
    
    public func object(at indexPath: IndexPath) -> ObjectType? {
        return container?.object(at: indexPath)
    }
    
    public func indexPath(for object: ObjectType) -> IndexPath? {
        return container?.indexPath(for: object)
    }
    
}
