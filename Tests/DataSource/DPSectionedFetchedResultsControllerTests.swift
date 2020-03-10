//
//  DPSectionedFetchedResultsControllerTests.swift
//  DPDataStorageTests
//
//  Created by Dmitriy Petrusevich on 5/10/19.
//  Copyright © 2019 dmitriy.petrusevich. All rights reserved.
//

import XCTest
@testable import DataSource

//@available(iOS 10.0, *)
//class DPSectionedFetchedResultsControllerTests: XCTestCase {
//    
//    func testMultiSectionFRCBehavior() {
//        let delegate = TestDelegate()
//        let delegateFRC = TestDelegate()
//        let storage = DataStorage(mergedModelFrom: [Bundle(for: type(of: self))], storageURL: nil)
//        let context: NSManagedObjectContext! = storage?.newMainQueueManagedObjectContext()
//        context.automaticallyMergesChangesFromParent = true
//
//        let request = BasicEntity.newFetchRequest(in: context)
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
//
//        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//        try! frc.performFetch()
//        let controller = DPSectionedFetchedResultsController(delegate: delegate, sectionHashCalculator: {return ($0 as! BasicEntity).section?.hashValue ?? 0}, sectionSortDescriptor: NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), frc: frc)
//
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
//        let testFRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(BasicEntity.section), cacheName: nil)
//        (testFRC as DataSourceContainerController).delegate = delegateFRC
//        try! testFRC.performFetch()
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
//            try? context.saveChanges()
//        }
//        context.performAndWait {
//            entity0 = BasicEntity.init(context: context)
//            entity0.value = "0"
//            entity0.section = "0"
//            try? context.saveChanges()
//        }
//        context.performAndWait {
//            entity1 = BasicEntity.init(context: context)
//            entity1.value = "1"
//            entity1.section = "1"
//            try? context.saveChanges()
//        }
//
//        XCTAssert(isContainersEqual(first: controller, second: testFRC))
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
//        XCTAssert(isContainersEqual(first: controller, second: testFRC))
//    }
//
//    func testKnownCase1() {
//        let delegate = TestDelegate()
//        let delegateFRC = TestDelegate()
//        
//        let storage = DPDataStorage(mergedModelFrom: [Bundle(for: type(of: self))], storageURL: nil)
//        let context: NSManagedObjectContext! = storage?.newMainQueueManagedObjectContext()
//        context.automaticallyMergesChangesFromParent = true
//
//        let request = BasicEntity.newFetchRequest(in: context)
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
//
//        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//        try! frc.performFetch()
//        let sectionedController = DPSectionedFetchedResultsController(delegate: delegate, sectionHashCalculator: {return ($0 as! BasicEntity).section?.hashValue ?? 0}, sectionSortDescriptor: NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), frc: frc)
//        let controller = DPContainerControllerBasedController(delegate: delegate, otherController: sectionedController)
//
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
//        let testFRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(BasicEntity.section), cacheName: nil)
//        (testFRC as DataSourceContainerController).delegate = delegateFRC
//        try! testFRC.performFetch()
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
//        XCTAssert(isContainersEqual(first: controller, second: testFRC))
//
//        context.performAndWait {
//            context.delete(entity0)
//            entity2.section = "1"
//            try? context.saveChanges()
//        }
//
//        XCTAssert(isContainersEqual(first: controller, second: testFRC))
//    }
//
//    func testKnownCase2() {
//        let delegate = TestDelegate()
//        let delegateFRC = TestDelegate()
//
//        let storage = DPDataStorage(mergedModelFrom: [Bundle(for: type(of: self))], storageURL: nil)
//        let context: NSManagedObjectContext! = storage?.newMainQueueManagedObjectContext()
//        context.automaticallyMergesChangesFromParent = true
//
//        let request = BasicEntity.newFetchRequest(in: context)
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
//
//        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//        try! frc.performFetch()
//        let sectionedController = DPSectionedFetchedResultsController(delegate: delegate, sectionHashCalculator: {return ($0 as! BasicEntity).section?.hashValue ?? 0}, sectionSortDescriptor: NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), frc: frc)
//        let controller = DPContainerControllerBasedController(delegate: delegate, otherController: sectionedController)
//
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
//        let testFRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(BasicEntity.section), cacheName: nil)
//        (testFRC as DataSourceContainerController).delegate = delegateFRC
//        try! testFRC.performFetch()
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
//        XCTAssert(isContainersEqual(first: controller, second: testFRC))
//
//        context.performAndWait {
//            entity2.section = "1"
//            try? context.saveChanges()
//        }
//
//        XCTAssert(isContainersEqual(first: controller, second: testFRC))
//    }
//
//    func testKnownCase3() {
//        let delegate = TestDelegate()
//        let delegateFRC = TestDelegate()
//
//        let storage = DPDataStorage(mergedModelFrom: [Bundle(for: type(of: self))], storageURL: nil)
//        let context: NSManagedObjectContext! = storage?.newMainQueueManagedObjectContext()
//        context.automaticallyMergesChangesFromParent = true
//
//        let request = BasicEntity.newFetchRequest(in: context)
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
//
//        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//        try! frc.performFetch()
//        let sectionedController = DPSectionedFetchedResultsController(delegate: delegate, sectionHashCalculator: {return ($0 as! BasicEntity).section?.hashValue ?? 0}, sectionSortDescriptor: NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), frc: frc)
//        let controller = DPContainerControllerBasedController(delegate: delegate, otherController: sectionedController)
//
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
//        let testFRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(BasicEntity.section), cacheName: nil)
//        (testFRC as DataSourceContainerController).delegate = delegateFRC
//        try! testFRC.performFetch()
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
//        XCTAssert(isContainersEqual(first: controller, second: testFRC))
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
//        let delegateFRC = TestDelegate()
//
//        let storage = DPDataStorage(mergedModelFrom: [Bundle(for: type(of: self))], storageURL: nil)
//        let context: NSManagedObjectContext! = storage?.newMainQueueManagedObjectContext()
//        context.automaticallyMergesChangesFromParent = true
//
//        let request = BasicEntity.newFetchRequest(in: context)
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
//
//        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//        try! frc.performFetch()
//        let sectionedController = DPSectionedFetchedResultsController(delegate: delegate, sectionHashCalculator: {return ($0 as! BasicEntity).section?.hashValue ?? 0}, sectionSortDescriptor: NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), frc: frc)
//        let controller = DPContainerControllerBasedController(delegate: delegate, otherController: sectionedController)
//
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
//        let testFRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(BasicEntity.section), cacheName: nil)
//        (testFRC as DataSourceContainerController).delegate = delegateFRC
//        try! testFRC.performFetch()
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
//        XCTAssert(isContainersEqual(first: controller, second: testFRC))
//
//        context.performAndWait {
//            entity2.section = "4"
//            try? context.saveChanges()
//        }
//
//        XCTAssert(isContainersEqual(first: controller, second: testFRC))
//    }
//
//    /// Check with UITableView
//    func testKnownCase5() {
//        let delegate = TestDelegate()
//        let delegateFRC = TestDelegate()
//
//        let storage = DPDataStorage(mergedModelFrom: [Bundle(for: type(of: self))], storageURL: nil)
//        let context: NSManagedObjectContext! = storage?.newMainQueueManagedObjectContext()
//        context.automaticallyMergesChangesFromParent = true
//
//        let request = BasicEntity.newFetchRequest(in: context)
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
//
//        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//        try! frc.performFetch()
//        let sectionedController = DPSectionedFetchedResultsController(delegate: delegate, sectionHashCalculator: {return ($0 as! BasicEntity).section?.hashValue ?? 0}, sectionSortDescriptor: NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), frc: frc)
//        let controller = DPContainerControllerBasedController(delegate: delegate, otherController: sectionedController)
//
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \BasicEntity.section, ascending: true), NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)]
//        let testFRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(BasicEntity.section), cacheName: nil)
//        (testFRC as DataSourceContainerController).delegate = delegateFRC
//        try! testFRC.performFetch()
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
//        XCTAssert(isContainersEqual(first: controller, second: testFRC))
//
//        context.performAndWait {
//            context.delete(entity0)
//            let entity4 = BasicEntity.init(context: context)
//            entity4.value = "4"
//            entity4.section = "1"
//            try? context.saveChanges()
//        }
//
//        XCTAssert(isContainersEqual(first: controller, second: testFRC))
//    }
//}
//
