//
//  DPContainerControllerBasedControllerTests.swift
//  DPDataStorageTests
//
//  Created by Dmitriy Petrusevich on 5/4/19.
//  Copyright © 2019 dmitriy.petrusevich. All rights reserved.
//

import XCTest
import DPDataStorage

class DPContainerControllerBasedControllerTests: XCTestCase {

    func testFRCBehavior() {
        let delegate = TestDelegate()
        let storage = DPDataStorage(mergedModelFrom:  [Bundle(for: type(of: self))], storageURL: nil)
        if let context = storage?.newMainQueueManagedObjectContext() {
            context.automaticallyMergesChangesFromParent = true

            let frc = BasicEntity.fetchedResultsController(nil, predicate: nil, sortDescriptors: [NSSortDescriptor(keyPath: \BasicEntity.value, ascending: true)], in: context)
            let container = DPContainerControllerBasedController(delegate: delegate, otherController: frc)

            var entity0: BasicEntity!
            var entity1: BasicEntity!
            var entity2: BasicEntity!

            context.performAndWait {
                entity0 = BasicEntity.init(context: context)
                entity0.value = "0"
                try? context.saveChanges()
            }
            context.performAndWait {
                entity1 = BasicEntity.init(context: context)
                entity1.value = "1"
                try? context.saveChanges()
            }
            context.performAndWait {
                entity2 = BasicEntity.init(context: context)
                entity2.value = "2"

                try? context.saveChanges()
            }

            context.performAndWait {
                context.delete(entity0)
                entity2.value = "2"
                entity1.value = "3"

                let entity4 = BasicEntity.init(context: context)
                entity4.value = "0"
                let entity5 = BasicEntity.init(context: context)
                entity5.value = "2"

                try? context.saveChanges()
            }

            XCTAssert(container.numberOfItems(inSection: 0) == frc.numberOfItems(inSection: 0))

            for i in 0 ..< container.numberOfItems(inSection: 0) {
                let o1 = container.object(at: IndexPath(item: i, section: 0)) as? BasicEntity
                let o2 = frc.object(at: IndexPath(item: i, section: 0)) as? BasicEntity
                XCTAssert(o1?.objectID == o2?.objectID)
            }

        } else {
            XCTFail()
        }
    }
}
