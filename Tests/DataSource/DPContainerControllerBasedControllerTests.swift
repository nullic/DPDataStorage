//
//  DPContainerControllerBasedControllerTests.swift
//  DPDataStorageTests
//
//  Created by Dmitriy Petrusevich on 5/4/19.
//  Copyright © 2019 dmitriy.petrusevich. All rights reserved.
//

import XCTest
@testable import DataSource

//class DPContainerControllerBasedControllerTests: XCTestCase {
//
//    func testSingleSectionFRCBehavior() {
//        let delegate = TestDelegate()
//        let storage = DPDataStorage(mergedModelFrom: [Bundle(for: type(of: self))], storageURL: nil)
//        let context: NSManagedObjectContext! = storage?.newMainQueueManagedObjectContext()
//        context.automaticallyMergesChangesFromParent = true
//
//        let frc = BasicEntity.fetchedResultsController(nil, predicate: nil, sortDescriptors: [NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)], in: context)
//        let controller = DPContainerControllerBasedController(delegate: delegate, otherController: frc)
//
//        var entity0: BasicEntity!
//        var entity1: BasicEntity!
//        var entity2: BasicEntity!
//
//        context.performAndWait {
//            entity0 = BasicEntity.init(context: context)
//            entity0.value = "0"
//            try? context.saveChanges()
//        }
//        context.performAndWait {
//            entity1 = BasicEntity.init(context: context)
//            entity1.value = "1"
//            try? context.saveChanges()
//        }
//        context.performAndWait {
//            entity2 = BasicEntity.init(context: context)
//            entity2.value = "2"
//
//            try? context.saveChanges()
//        }
//
//        context.performAndWait {
//            context.delete(entity0)
//            entity2.value = "2"
//            entity1.value = "3"
//
//            let entity4 = BasicEntity.init(context: context)
//            entity4.value = "0"
//            let entity5 = BasicEntity.init(context: context)
//            entity5.value = "2"
//
//            try? context.saveChanges()
//        }
//
//        XCTAssert(isContainersEqual(first: controller, second: frc))
//    }
//
//    func testMultiSectionFRCBehavior() {
//        let delegate = TestDelegate()
//        let storage = DPDataStorage(mergedModelFrom: [Bundle(for: type(of: self))], storageURL: nil)
//        let context: NSManagedObjectContext! = storage?.newMainQueueManagedObjectContext()
//        context.automaticallyMergesChangesFromParent = true
//
//        let request = BasicEntity.newFetchRequest(in: context)
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
//
//        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(BasicEntity.section), cacheName: nil)
//        try! frc.performFetch()
//        let controller = DPContainerControllerBasedController(delegate: delegate, otherController: frc)
//
//
//        var entity0: BasicEntity!
//        var entity1: BasicEntity!
//        var entity2: BasicEntity!
//
//        context.performAndWait {
//            entity2 = BasicEntity.init(context: context)
//            entity2.value = "2"
//            entity2.section = "2"
//
//            entity0 = BasicEntity.init(context: context)
//            entity0.value = "0"
//            entity0.section = "0"
//
//            entity1 = BasicEntity.init(context: context)
//            entity1.value = "1"
//            entity1.section = "1"
//
//            try? context.saveChanges()
//        }
//
//        XCTAssert(isContainersEqual(first: controller, second: frc))
//
//        context.performAndWait {
//            context.delete(entity0)
//            entity2.section = "1"
//            entity1.value = "3"
//
//            let entity4 = BasicEntity.init(context: context)
//            entity4.value = "0"
//            entity4.section = "0"
//            let entity5 = BasicEntity.init(context: context)
//            entity5.value = "n2"
//            entity5.section = "2"
//
//            try? context.saveChanges()
//        }
//
//        XCTAssert(isContainersEqual(first: controller, second: frc))
//    }
//
//    func testMultiSectionFRCBehaviorCase2() {
//        let delegate = TestDelegate()
//        let storage = DPDataStorage(mergedModelFrom: [Bundle(for: type(of: self))], storageURL: nil)
//        let context: NSManagedObjectContext! = storage?.newMainQueueManagedObjectContext()
//        context.automaticallyMergesChangesFromParent = true
//
//        let request = BasicEntity.newFetchRequest(in: context)
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
//
//        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(BasicEntity.section), cacheName: nil)
//        try! frc.performFetch()
//        let controller = DPContainerControllerBasedController(delegate: delegate, otherController: frc)
//
//
//        var entity0: BasicEntity!
//        var entity1: BasicEntity!
//        var entity2: BasicEntity!
//
//        context.performAndWait {
//            entity0 = BasicEntity.init(context: context)
//            entity0.value = "0"
//            entity0.section = "0"
//
//            entity1 = BasicEntity.init(context: context)
//            entity1.value = "1"
//            entity1.section = "1"
//
//            entity2 = BasicEntity.init(context: context)
//            entity2.value = "2"
//            entity2.section = "2"
//
//            try? context.saveChanges()
//        }
//
//        XCTAssert(isContainersEqual(first: controller, second: frc))
//
//        context.performAndWait {
//            context.delete(entity0)
//            let entity4 = BasicEntity.init(context: context)
//            entity4.value = "4"
//            entity4.section = "1"
//            try? context.saveChanges()
//        }
//
//        XCTAssert(isContainersEqual(first: controller, second: frc))
//    }
//
//    func testKnownCaseWithFRC() {
//        let delegate = TestDelegate()
//        let storage = DPDataStorage(mergedModelFrom: [Bundle(for: type(of: self))], storageURL: nil)
//        let context: NSManagedObjectContext! = storage?.newMainQueueManagedObjectContext()
//        context.automaticallyMergesChangesFromParent = true
//
//        let request = BasicEntity.newFetchRequest(in: context)
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
//
//        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(BasicEntity.section), cacheName: nil)
//        try! frc.performFetch()
//        let controller = DPContainerControllerBasedController(delegate: delegate, otherController: frc)
//
//
//        var entity0: BasicEntity!
//        var entity1: BasicEntity!
//        var entity2: BasicEntity!
//
//        context.performAndWait {
//            entity0 = BasicEntity.init(context: context)
//            entity0.value = "0"
//            entity0.section = "0"
//
//            entity1 = BasicEntity.init(context: context)
//            entity1.value = "1"
//            entity1.section = "2"
//
//            entity2 = BasicEntity.init(context: context)
//            entity2.value = "2"
//            entity2.section = "2"
//
//            try? context.saveChanges()
//        }
//
//        context.performAndWait {
//            XCTAssert(controller.numberOfSections() == 2)
//            XCTAssert(controller.numberOfItems(inSection: 0) == 1)
//            XCTAssert(controller.numberOfItems(inSection: 1) == 2)
//
//            var object = controller.object(at: IndexPath(row: 0, section: 0)) as? BasicEntity
//            XCTAssert(object?.value == "0")
//            object = controller.object(at: IndexPath(row: 0, section: 1)) as? BasicEntity
//            XCTAssert(object?.value == "1")
//            object = controller.object(at: IndexPath(row: 1, section: 1)) as? BasicEntity
//            XCTAssert(object?.value == "2")
//        }
//
//        context.performAndWait {
//            context.delete(entity0)
//            entity2.section = "1"
//            try? context.saveChanges()
//        }
//
//        XCTAssert(isContainersEqual(first: controller, second: frc))
//    }
//
//    func testKnownCase3() {
//        let delegate = TestDelegate()
//
//        let storage = DPDataStorage(mergedModelFrom: [Bundle(for: type(of: self))], storageURL: nil)
//        let context: NSManagedObjectContext! = storage?.newMainQueueManagedObjectContext()
//        context.automaticallyMergesChangesFromParent = true
//
//        let request = BasicEntity.newFetchRequest(in: context)
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
//        let testFRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(BasicEntity.section), cacheName: nil)
//        try! testFRC.performFetch()
//
//        let controller = DPContainerControllerBasedController(delegate: delegate, otherController: testFRC)
//
//
//        var entity0: BasicEntity!
//        var entity2: BasicEntity!
//
//        context.performAndWait {
//            entity0 = BasicEntity.init(context: context)
//            entity0.section = "0"
//            entity0.value = "0"
//
//            entity2 = BasicEntity.init(context: context)
//            entity2.section = "2"
//            entity2.value = "2"
//
//            try? context.saveChanges()
//        }
//
//        context.performAndWait {
//            entity2.section = "1"
//            try? context.saveChanges()
//        }
//
//        XCTAssert(isContainersEqual(first: controller, second: testFRC))
//    }
//
//    func testKnownCase4() {
//        let delegate = TestDelegate()
//
//        let storage = DPDataStorage(mergedModelFrom: [Bundle(for: type(of: self))], storageURL: nil)
//        let context: NSManagedObjectContext! = storage?.newMainQueueManagedObjectContext()
//        context.automaticallyMergesChangesFromParent = true
//
//        let request = BasicEntity.newFetchRequest(in: context)
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
//        let testFRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(BasicEntity.section), cacheName: nil)
//        try! testFRC.performFetch()
//
//        let controller = DPContainerControllerBasedController(delegate: delegate, otherController: testFRC)
//
//
//        var entity0: BasicEntity!
//        var entity2: BasicEntity!
//
//        context.performAndWait {
//            entity0 = BasicEntity.init(context: context)
//            entity0.section = "0"
//            entity0.value = "0"
//
//            entity2 = BasicEntity.init(context: context)
//            entity2.section = "2"
//            entity2.value = "2"
//
//            try? context.saveChanges()
//        }
//
//        context.performAndWait {
//            entity2.section = "4"
//            try? context.saveChanges()
//        }
//
//        XCTAssert(isContainersEqual(first: controller, second: testFRC))
//    }
//}
