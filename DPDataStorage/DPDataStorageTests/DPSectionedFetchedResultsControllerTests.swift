//
//  DPSectionedFetchedResultsControllerTests.swift
//  DPDataStorageTests
//
//  Created by Dmitriy Petrusevich on 5/10/19.
//  Copyright © 2019 dmitriy.petrusevich. All rights reserved.
//

import XCTest
import DPDataStorage

class DPSectionedFetchedResultsControllerTests: XCTestCase {
    
    func testMultiSectionFRCBehavior() {
        let delegate = TestDelegate()
        let delegateFRC = TestDelegate()
        let storage = DPDataStorage(mergedModelFrom:  [Bundle(for: type(of: self))], storageURL: nil)
        let context: NSManagedObjectContext! = storage?.newMainQueueManagedObjectContext()
        context.automaticallyMergesChangesFromParent = true

        let request = BasicEntity.newFetchRequest(in: context)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]

        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        try! frc.performFetch()
        let controller = DPSectionedFetchedResultsController(delegate: delegate, sectionHashCalculator: {return ($0 as! BasicEntity).section?.hashValue ?? 0}, sectionSortDescriptor: NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), frc: frc)

        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
        let testFRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(BasicEntity.section), cacheName: nil)
        (testFRC as DataSourceContainerController).delegate = delegateFRC
        try! testFRC.performFetch()


        var entity0: BasicEntity!
        var entity1: BasicEntity!
        var entity2: BasicEntity!

        context.performAndWait {
            entity2 = BasicEntity.init(context: context)
            entity2.value = "2"
            entity2.section = "2"
            try? context.saveChanges()
        }
        context.performAndWait {
            entity0 = BasicEntity.init(context: context)
            entity0.value = "0"
            entity0.section = "0"
            try? context.saveChanges()
        }
        context.performAndWait {
            entity1 = BasicEntity.init(context: context)
            entity1.value = "1"
            entity1.section = "1"
            try? context.saveChanges()
        }

        XCTAssert(isContainersEqual(first: controller, second: testFRC))

        context.performAndWait {
            context.delete(entity0)
            entity2.section = "1"
            entity1.value = "3"

            let entity4 = BasicEntity.init(context: context)
            entity4.value = "0"
            entity4.section = "0"
            let entity5 = BasicEntity.init(context: context)
            entity5.value = "n2"
            entity5.section = "2"

            try? context.saveChanges()
        }

        XCTAssert(isContainersEqual(first: controller, second: testFRC))
    }

    func testKnownCase1() {
        let delegate = TestDelegate()
        let delegateFRC = TestDelegate()
        
        let storage = DPDataStorage(mergedModelFrom:  [Bundle(for: type(of: self))], storageURL: nil)
        let context: NSManagedObjectContext! = storage?.newMainQueueManagedObjectContext()
        context.automaticallyMergesChangesFromParent = true

        let request = BasicEntity.newFetchRequest(in: context)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]

        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        try! frc.performFetch()
        let controller = DPSectionedFetchedResultsController(delegate: delegate, sectionHashCalculator: {return ($0 as! BasicEntity).section?.hashValue ?? 0}, sectionSortDescriptor: NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), frc: frc)

        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
        let testFRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(BasicEntity.section), cacheName: nil)
        (testFRC as DataSourceContainerController).delegate = delegateFRC
        try! testFRC.performFetch()


        var entity0: BasicEntity!
        var entity1: BasicEntity!
        var entity2: BasicEntity!

        context.performAndWait {
            entity0 = BasicEntity.init(context: context)
            entity0.value = "0"
            entity0.section = "0"

            entity1 = BasicEntity.init(context: context)
            entity1.value = "1"
            entity1.section = "2"

            entity2 = BasicEntity.init(context: context)
            entity2.value = "2"
            entity2.section = "2"

            try? context.saveChanges()
        }

        XCTAssert(isContainersEqual(first: controller, second: testFRC))

        context.performAndWait {
            context.delete(entity0)
            entity2.section = "1"
            try? context.saveChanges()
        }

       XCTAssert(isContainersEqual(first: controller, second: testFRC))
    }

    func testKnownCase2() {
        let delegate = TestDelegate()
        let delegateFRC = TestDelegate()

        let storage = DPDataStorage(mergedModelFrom:  [Bundle(for: type(of: self))], storageURL: nil)
        let context: NSManagedObjectContext! = storage?.newMainQueueManagedObjectContext()
        context.automaticallyMergesChangesFromParent = true

        let request = BasicEntity.newFetchRequest(in: context)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]

        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        try! frc.performFetch()
        let controller = DPSectionedFetchedResultsController(delegate: delegate, sectionHashCalculator: {return ($0 as! BasicEntity).section?.hashValue ?? 0}, sectionSortDescriptor: NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), frc: frc)

        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
        let testFRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(BasicEntity.section), cacheName: nil)
        (testFRC as DataSourceContainerController).delegate = delegateFRC
        try! testFRC.performFetch()


        var entity0: BasicEntity!
        var entity1: BasicEntity!
        var entity2: BasicEntity!

        context.performAndWait {
            entity0 = BasicEntity.init(context: context)
            entity0.value = "0"
            entity0.section = "0"

            entity1 = BasicEntity.init(context: context)
            entity1.value = "1"
            entity1.section = "2"

            entity2 = BasicEntity.init(context: context)
            entity2.value = "2"
            entity2.section = "2"

            try? context.saveChanges()
        }

        XCTAssert(isContainersEqual(first: controller, second: testFRC))

        context.performAndWait {
            entity2.section = "1"
            try? context.saveChanges()
        }

        XCTAssert(isContainersEqual(first: controller, second: testFRC))
    }

    func isContainersEqual(first: DataSourceContainerController, second: DataSourceContainerController) -> Bool {
        guard first.numberOfSections() == second.numberOfSections() else {
            return false
        }
        for s in 0 ..< first.numberOfSections() {
            guard first.numberOfItems(inSection: s) == second.numberOfItems(inSection: s) else {
                return false
            }

            for i in 0 ..< first.numberOfItems(inSection: s) {
                let o1 = first.object(at: IndexPath(item: i, section: s)) as? BasicEntity
                let o2 = second.object(at: IndexPath(item: i, section: s)) as? BasicEntity
                guard o1?.objectID == o2?.objectID else {
                    return false
                }
            }
        }
        return true
    }
}

