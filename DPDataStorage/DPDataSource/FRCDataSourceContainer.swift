//
//  FRCDataSourceContainer.swift
//  DPDataStorage
//
//  Created by Alex on 10/9/17.
//  Copyright © 2017 EffectiveSoft. All rights reserved.
//

import UIKit

public class FRCDataSourceContainer<ResultType: NSFetchRequestResult>: DataSourceContainer<ResultType> {

    fileprivate let fetchedResultController: NSFetchedResultsController<ResultType>
    fileprivate var delegateForwarder: CoreDataDelegateForwarder<ResultType>
    
    public init(fetchRequest: NSFetchRequest<ResultType>,
                context: NSManagedObjectContext,
                sectionNameKeyPath: String?,
                delegate: DataSourceContainerDelegate?) {
        fetchedResultController =
            NSFetchedResultsController(fetchRequest: fetchRequest,
                                       managedObjectContext: context,
                                       sectionNameKeyPath: sectionNameKeyPath,
                                       cacheName: nil)
        delegateForwarder = CoreDataDelegateForwarder<ResultType>(delegate: delegate)
        super.init(delegate: delegate)
        fetchedResultController.delegate = delegateForwarder
        try! fetchedResultController.performFetch()
        delegateForwarder.container = self
    }

    override public var sections: [DataSourceSectionInfo]? {
        get {
            return fetchedResultController.sections
        }
    }
    
    override public var fetchedObjects: [ResultType]? {
        get {
            return fetchedResultController.fetchedObjects
        }
    }
    
    override public func object(at indexPath: IndexPath) -> ResultType {
        return fetchedResultController.object(at: indexPath)
    }
    
    override public func indexPath(for object: ResultType) -> IndexPath? {
        return fetchedResultController.indexPath(forObject: object)
    }
    
    override public func numberOfSections() -> Int {
        return fetchedResultController.numberOfSections()
    }
    
    override public func numberOfItems(in section: Int) -> Int? {
        return fetchedResultController.numberOfItems(inSection:section)
    }

}

class CoreDataDelegateForwarder<ResultType: NSFetchRequestResult>: NSObject, NSFetchedResultsControllerDelegate {
    
    let delegate: DataSourceContainerDelegate?
    weak var container: FRCDataSourceContainer<ResultType>?
    
    init(delegate: DataSourceContainerDelegate? = nil, container: FRCDataSourceContainer<ResultType>? = nil) {
        self.delegate = delegate
        self.container = container
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        guard let container = container else { return }
        delegate?.container(container, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        guard let container = container else { return }
        delegate?.container(container, didChange: sectionInfo, atSectionIndex: sectionIndex, for: type)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let container = container else { return }
        delegate?.containerWillChangeContent(container)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let container = container else { return }
        delegate?.containerDidChangeContent(container)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    sectionIndexTitleForSectionName sectionName: String) -> String? {
        guard let container = container else { return nil }
        return delegate?.container(container, sectionIndexTitleForSectionName: sectionName)
    }
    
}
