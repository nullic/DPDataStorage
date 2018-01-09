//
//  DataSourceContainer.swift
//  DPDataStorage
//
//  Created by Alex on 10/6/17.
//  Copyright © 2017 EffectiveSoft. All rights reserved.
//

import Foundation

public typealias DataSourceSectionInfo = NSFetchedResultsSectionInfo
public typealias DataSourceObjectChangeType = NSFetchedResultsChangeType

public protocol DataSourceContainerProtocol { }

public class DataSourceContainer<ResultType>: DataSourceContainerProtocol {
    
    // MARK: Initializer
    
    init(delegate: DataSourceContainerDelegate?) {
        self.delegate = delegate
    }

    // MARK: Delegate

    public var delegate: DataSourceContainerDelegate?

    // MARK: Methods for overriding in subclasses
    
    open var sections: [DataSourceSectionInfo]? {
        get {
            return nil
        }
    }
    
    open var fetchedObjects: [ResultType]? {
        get {
            return nil
        }
    }

    open var hasData: Bool {
        get {
            if let fetchedObjects = fetchedObjects {
                return fetchedObjects.count > 0
            }
            return false
        }
    }

    open func object(at indexPath: IndexPath) -> ResultType? {
        return nil
    }
    
    open func indexPath(for object: ResultType) -> IndexPath? {
        return nil
    }

    open func numberOfSections() -> Int? {
        return nil
    }
    
    open func numberOfItems(in section: Int) -> Int? {
        return nil
    }
}

// MARK: DataSourceContainerDelegate

public protocol DataSourceContainerDelegate {
    
    func containerWillChangeContent(_ container: DataSourceContainerProtocol)
    
    func container(_ container: DataSourceContainerProtocol,
                   didChange anObject: Any,
                   at indexPath: IndexPath?,
                   for type: DataSourceObjectChangeType,
                   newIndexPath: IndexPath?)
    
    func container(_ container: DataSourceContainerProtocol,
                   didChange sectionInfo: DataSourceSectionInfo,
                   atSectionIndex sectionIndex: Int,
                   for type: DataSourceObjectChangeType)
    
    func container(_ container: DataSourceContainerProtocol,
                   sectionIndexTitleForSectionName sectionName: String) -> String?
    
    func containerDidChangeContent(_ container: DataSourceContainerProtocol)

}
