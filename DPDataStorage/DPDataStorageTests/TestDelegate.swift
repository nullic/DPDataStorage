//
//  TestDelegate.swift
//  DPDataStorageTests
//
//  Created by Dmitriy Petrusevich on 5/4/19.
//  Copyright © 2019 dmitriy.petrusevich. All rights reserved.
//

import Foundation
import DPDataStorage

extension NSFetchedResultsChangeType {
    var stringValue: String {
        switch self {
        case .insert: return "INSERT"
        case .delete: return "DELETE"
        case .update: return "UPDATE"
        case .move: return "MOVE"
        @unknown default: return "UNKNOWN"
        }
    }
}

class TestDelegate: NSObject, DataSourceContainerControllerDelegate {
    struct ItemChange: CustomStringConvertible {
        let type: NSFetchedResultsChangeType
        let indexPath: IndexPath?
        let newIndexPath: IndexPath?
        let anObject: Any

        var description: String {
            return "\(type.stringValue): \(indexPath?.description ?? "nil") -> \(newIndexPath?.description ?? "nil")"
        }
    }

    struct SectionChange: CustomStringConvertible {
        let type: NSFetchedResultsChangeType
        let sectionIndex: UInt
        let sectionInfo: NSFetchedResultsSectionInfo

        var description: String {
            return "\(type.stringValue): \(sectionIndex)"
        }
    }

    private(set) var itemChanges: [ItemChange] = []
    private(set) var sectionChanges: [SectionChange] = []
    private(set) var allChanges: [Any] = []

    func controllerWillChangeContent(_ controller: DataSourceContainerController) {
        allChanges = []
        itemChanges = []
        sectionChanges = []
    }

    func controller(_ controller: DataSourceContainerController, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let change = ItemChange(type: type, indexPath: indexPath, newIndexPath: newIndexPath, anObject: anObject)
        itemChanges.append(change)
        allChanges.append(change)
    }

    func controller(_ controller: DataSourceContainerController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, at sectionIndex: UInt, for type: NSFetchedResultsChangeType) {
        let change = SectionChange(type: type, sectionIndex: sectionIndex, sectionInfo: sectionInfo)
        sectionChanges.append(change)
        allChanges.append(change)
    }
}

