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
    
    var delegate: DataSourceContainerDelegate?
    var sections: [DataSourceSectionInfo]? {
        get {
            return nil
        }
    }
    
    var fetchedObjects: [ResultType]? {
        get {
            return nil
        }
    }

    public var hasData: Bool {
        get {
            if let fetchedObjects = fetchedObjects {
                return fetchedObjects.count > 0
            }
            return false
        }
    }

    func object(at indexPath: IndexPath) -> ResultType? {
        return nil
    }
    
    func indexPath(for object: ResultType) -> IndexPath? {
        return nil
    }

    func numberOfSections() -> Int? {
        return nil
    }
    
    func numberOfItems(in section: Int) -> Int? {
        return nil
    }
}

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
