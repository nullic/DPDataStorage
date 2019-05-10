//
//  DPArrayControllerTests.swift
//  DPDataStorageTests
//
//  Created by Dmitriy Petrusevich on 5/4/19.
//  Copyright © 2019 dmitriy.petrusevich. All rights reserved.
//

import XCTest
import DPDataStorage

class DPArrayControllerTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSetObjects() {
        let delegate = TestDelegate()
        let controller = DPArrayController(delegate: delegate)

        let array = [TestObject(section: "1", value: "3"), TestObject(section: "1", value: "1"), TestObject(section: "1", value: "2")]
        controller.startUpdating()
        controller.setObjects(array, atSection: 0)
        controller.endUpdating()

        XCTAssert(delegate.itemChanges.count == array.count)
        XCTAssert(delegate.sectionChanges.count == 1)
        XCTAssert(controller.numberOfSections() == 1)
        XCTAssert(controller.numberOfItems(inSection: 0) == array.count)

        var object = controller.object(at: IndexPath(row: 0, section: 0)) as? TestObject
        XCTAssert(object?.value == array[0].value)
        object = controller.object(at: IndexPath(row: 1, section: 0)) as? TestObject
        XCTAssert(object?.value == array[1].value)
        object = controller.object(at: IndexPath(row: 2, section: 0)) as? TestObject
        XCTAssert(object?.value == array[2].value)


        let newArray = [TestObject(section: "1", value: "9"), TestObject(section: "1", value: "7")]
        controller.startUpdating()
        controller.setObjects(newArray, atSection: 0)
        controller.endUpdating()

        XCTAssert(delegate.itemChanges.count == (newArray.count + array.count))
        XCTAssert(delegate.itemChanges[3].newIndexPath == IndexPath(row: 0, section: 0))
        XCTAssert(delegate.itemChanges[4].newIndexPath == IndexPath(row: 1, section: 0))

        XCTAssert(delegate.sectionChanges.count == 0)
        XCTAssert(controller.numberOfSections() == 1)
        XCTAssert(controller.numberOfItems(inSection: 0) == newArray.count)

        object = controller.object(at: IndexPath(row: 0, section: 0)) as? TestObject
        XCTAssert(object?.value == newArray[0].value)
        object = controller.object(at: IndexPath(row: 1, section: 0)) as? TestObject
        XCTAssert(object?.value == newArray[1].value)
    }

    func testAddObjects() {
        let delegate = TestDelegate()
        let controller = DPArrayController(delegate: delegate)

        controller.startUpdating()
        controller.insertSection(at: 0)
        controller.endUpdating()

        XCTAssert(delegate.sectionChanges.count == 1)

        let array = [TestObject(section: "1", value: "3"), TestObject(section: "1", value: "1"), TestObject(section: "1", value: "2")]
        controller.startUpdating()
        controller.add(array, atSection: 0)
        controller.endUpdating()

        XCTAssert(delegate.itemChanges.count == array.count)
        XCTAssert(delegate.sectionChanges.count == 0)
        XCTAssert(controller.numberOfSections() == 1)
        XCTAssert(controller.numberOfItems(inSection: 0) == array.count)

        controller.startUpdating()
        controller.add(array, atSection: 0)
        controller.endUpdating()

        XCTAssert(delegate.itemChanges.count == array.count)
        XCTAssert(delegate.sectionChanges.count == 0)
        XCTAssert(controller.numberOfSections() == 1)
        XCTAssert(controller.numberOfItems(inSection: 0) == 2*array.count)

        XCTAssert(delegate.itemChanges[0].newIndexPath == IndexPath(row: array.count, section: 0))
        XCTAssert(delegate.itemChanges[1].newIndexPath == IndexPath(row: array.count + 1, section: 0))

    }

    func testInsertAtEndObjects() {
        let delegate = TestDelegate()
        let controller = DPArrayController(delegate: delegate)

        let array = [TestObject(section: "1", value: "1"), TestObject(section: "1", value: "1"), TestObject(section: "1", value: "1")]
        controller.startUpdating()
        controller.setObjects(array, atSection: 0)
        controller.endUpdating()

        XCTAssert(controller.numberOfSections() == 1)
        XCTAssert(controller.numberOfItems(inSection: 0) == array.count)

        controller.startUpdating()
        controller.insert(TestObject(section: "3", value: String(array.count)), atIndextPath: IndexPath(row: array.count, section: 0))
        controller.insert(TestObject(section: "3", value: String(array.count + 1)), atIndextPath: IndexPath(row: array.count + 1, section: 0))
        controller.endUpdating()

        XCTAssert(delegate.itemChanges.count == 2)
        XCTAssert(delegate.sectionChanges.count == 0)
        XCTAssert(controller.numberOfSections() == 1)
        XCTAssert(controller.numberOfItems(inSection: 0) == array.count + 2)

        XCTAssert(delegate.itemChanges[0].newIndexPath == IndexPath(row: array.count, section: 0))
        XCTAssert(delegate.itemChanges[1].newIndexPath == IndexPath(row: array.count + 1, section: 0))

        var object = controller.object(at: IndexPath(row: array.count, section: 0)) as? TestObject
        XCTAssert(object?.value == String(array.count))
        object = controller.object(at: IndexPath(row: array.count + 1, section: 0)) as? TestObject
        XCTAssert(object?.value == String(array.count + 1))
    }

    func testInsertPlaceholders() {
        let delegate = TestDelegate()
        let controller = DPArrayController(delegate: delegate)

        let array = [TestObject(section: "1", value: "1"), TestObject(section: "1", value: "1"), TestObject(section: "1", value: "1")]
        controller.startUpdating()
        controller.setObjects(array, atSection: 0)
        controller.endUpdating()

        XCTAssert(controller.numberOfSections() == 1)
        XCTAssert(controller.numberOfItems(inSection: 0) == array.count)

        controller.startUpdating()
        controller.insert(TestObject(section: "3", value: String(array.count + 1)), atIndextPath: IndexPath(row: array.count + 1, section: 0))
        controller.insert(TestObject(section: "3", value: String(array.count)), atIndextPath: IndexPath(row: array.count, section: 0))
        controller.endUpdating()

        XCTAssert(delegate.itemChanges.count == 2)
        XCTAssert(delegate.sectionChanges.count == 0)
        XCTAssert(controller.numberOfSections() == 1)
        XCTAssert(controller.numberOfItems(inSection: 0) == array.count + 2)

        XCTAssert(delegate.itemChanges[0].newIndexPath == IndexPath(row: array.count + 1, section: 0))
        XCTAssert(delegate.itemChanges[1].newIndexPath == IndexPath(row: array.count, section: 0))

        var object = controller.object(at: IndexPath(row: array.count, section: 0)) as? TestObject
        XCTAssert(object?.value == String(array.count))
        object = controller.object(at: IndexPath(row: array.count + 1, section: 0)) as? TestObject
        XCTAssert(object?.value == String(array.count + 1))
    }

    func testMixedChanges() {
        let delegate = TestDelegate()
        let controller = DPArrayController(delegate: delegate)

        let array = [TestObject(section: "o", value: "1"), TestObject(section: "o", value: "2"), TestObject(section: "o", value: "3")]
        controller.startUpdating()
        controller.setObjects(array, atSection: 0)
        controller.endUpdating()

        XCTAssert(controller.numberOfSections() == 1)
        XCTAssert(controller.numberOfItems(inSection: 0) == array.count)

        controller.startUpdating()
        controller.insert(TestObject(section: "insert", value: "0"), atIndextPath: IndexPath(row: 0, section: 0))
        controller.reloadObject(atIndextPath: IndexPath(row: 0, section: 0))
        controller.moveObject(atIndextPath: IndexPath(row: 1, section: 0), to: IndexPath(row: 3, section: 0))
        controller.endUpdating()

        XCTAssert(delegate.itemChanges.count == 3)
        XCTAssert(delegate.sectionChanges.count == 0)
        XCTAssert(controller.numberOfSections() == 1)
        XCTAssert(controller.numberOfItems(inSection: 0) == array.count + 1)

        var object = controller.object(at: IndexPath(row: 0, section: 0)) as? TestObject
        XCTAssert(object?.value == "0")
        object = controller.object(at: IndexPath(row: 1, section: 0)) as? TestObject
        XCTAssert(object?.value == "1")
        object = controller.object(at: IndexPath(row: 2, section: 0)) as? TestObject
        XCTAssert(object?.value == "3")
        object = controller.object(at: IndexPath(row: 3, section: 0)) as? TestObject
        XCTAssert(object?.value == "2")
    }

    func testMixedChanges2() {
        let delegate = TestDelegate()
        let controller = DPArrayController(delegate: delegate)

        let array = [TestObject(section: "o", value: "1"), TestObject(section: "o", value: "2"), TestObject(section: "o", value: "3")]
        controller.startUpdating()
        controller.setObjects(array, atSection: 0)
        controller.endUpdating()

        XCTAssert(controller.numberOfSections() == 1)
        XCTAssert(controller.numberOfItems(inSection: 0) == array.count)

        controller.startUpdating()
        controller.insert(TestObject(section: "insert", value: "0"), atIndextPath: IndexPath(row: 3, section: 0))
        controller.moveObject(atIndextPath: IndexPath(row: 1, section: 0), to: IndexPath(row: 2, section: 0))
        controller.reloadObject(atIndextPath: IndexPath(row: 0, section: 0))
        controller.endUpdating()

        XCTAssert(delegate.itemChanges.count == 3)
        XCTAssert(delegate.sectionChanges.count == 0)
        XCTAssert(controller.numberOfSections() == 1)
        XCTAssert(controller.numberOfItems(inSection: 0) == array.count + 1)

        var object = controller.object(at: IndexPath(row: 0, section: 0)) as? TestObject
        XCTAssert(object?.value == "1")
        object = controller.object(at: IndexPath(row: 1, section: 0)) as? TestObject
        XCTAssert(object?.value == "3")
        object = controller.object(at: IndexPath(row: 2, section: 0)) as? TestObject
        XCTAssert(object?.value == "2")
        object = controller.object(at: IndexPath(row: 3, section: 0)) as? TestObject
        XCTAssert(object?.value == "0")
    }
}
