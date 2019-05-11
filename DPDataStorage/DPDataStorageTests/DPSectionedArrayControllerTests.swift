//
//  DPSectionedArrayControllerTests.swift
//  DPDataStorageTests
//
//  Created by Dmitriy Petrusevich on 5/4/19.
//  Copyright © 2019 dmitriy.petrusevich. All rights reserved.
//

import XCTest
import DPDataStorage

class DPSectionedArrayControllerTests: XCTestCase {

    func testSetObjectsSameSection() {
        let controller = DPSectionedArrayController(delegate: nil, sectionHashCalculator: TestObject.sectionHash, sectionSortDescriptor: TestObject.sectionSort)

        var array = [TestObject(section: "1", value: "3"), TestObject(section: "1", value: "1"), TestObject(section: "1", value: "2")]
        controller.setObjects(array)

        XCTAssert(controller.numberOfSections() == 1)
        XCTAssert(controller.numberOfItems(inSection: 0) == 3)

        var object = controller.object(at: IndexPath(row: 0, section: 0)) as? TestObject
        XCTAssert(object?.value == array[0].value)
        object = controller.object(at: IndexPath(row: 1, section: 0)) as? TestObject
        XCTAssert(object?.value == array[1].value)
        object = controller.object(at: IndexPath(row: 2, section: 0)) as? TestObject
        XCTAssert(object?.value == array[2].value)


        array = [TestObject(section: "1", value: "2"), TestObject(section: "1", value: "3"), TestObject(section: "1", value: "1")]
        controller.setObjects(array)

        XCTAssert(controller.numberOfSections() == 1)
        XCTAssert(controller.numberOfItems(inSection: 0) == 3)

        object = controller.object(at: IndexPath(row: 0, section: 0)) as? TestObject
        XCTAssert(object?.value == array[0].value)
        object = controller.object(at: IndexPath(row: 1, section: 0)) as? TestObject
        XCTAssert(object?.value == array[1].value)
        object = controller.object(at: IndexPath(row: 2, section: 0)) as? TestObject
        XCTAssert(object?.value == array[2].value)
    }

    func testSetObjectsDifferentSection111() {
        let controller = DPSectionedArrayController(delegate: nil, sectionHashCalculator: TestObject.sectionHash, sectionSortDescriptor: TestObject.sectionSort)

        let array = [TestObject(section: "1", value: "1"), TestObject(section: "2", value: "2"), TestObject(section: "3", value: "3")]
        controller.setObjects(array)

        XCTAssert(controller.numberOfSections() == 3)
        XCTAssert(controller.numberOfItems(inSection: 0) == 1)
        XCTAssert(controller.numberOfItems(inSection: 1) == 1)
        XCTAssert(controller.numberOfItems(inSection: 2) == 1)

        var object = controller.object(at: IndexPath(row: 0, section: 0)) as? TestObject
        XCTAssert(object?.value == "1")
        object = controller.object(at: IndexPath(row: 0, section: 1)) as? TestObject
        XCTAssert(object?.value == "2")
        object = controller.object(at: IndexPath(row: 0, section: 2)) as? TestObject
        XCTAssert(object?.value == "3")
    }

    func testSetObjectsDifferentSectionGroup21() {
        let controller = DPSectionedArrayController(delegate: nil, sectionHashCalculator: TestObject.sectionHash, sectionSortDescriptor: TestObject.sectionSort)

        let array = [TestObject(section: "3", value: "1"), TestObject(section: "1", value: "5"), TestObject(section: "1", value: "3")]
        controller.setObjects(array)

        XCTAssert(controller.numberOfSections() == 2)
        XCTAssert(controller.numberOfItems(inSection: 0) == 2)
        XCTAssert(controller.numberOfItems(inSection: 1) == 1)

        var object = controller.object(at: IndexPath(row: 0, section: 0)) as? TestObject
        XCTAssert(object?.value == "5")
        object = controller.object(at: IndexPath(row: 1, section: 0)) as? TestObject
        XCTAssert(object?.value == "3")
        object = controller.object(at: IndexPath(row: 0, section: 1)) as? TestObject
        XCTAssert(object?.value == "1")
    }

    func testReloadObjectNoChangesSameSection() {
        let delegate = TestDelegate()
        let controller = DPSectionedArrayController(delegate: delegate, sectionHashCalculator: TestObject.sectionHash, sectionSortDescriptor: TestObject.sectionSort)

        let array = [TestObject(section: "1", value: "1"), TestObject(section: "1", value: "2"), TestObject(section: "1", value: "3")]
        controller.setObjects(array)

        XCTAssert(controller.numberOfSections() == 1)
        XCTAssert(controller.numberOfItems(inSection: 0) == 3)

        var object = controller.object(at: IndexPath(row: 0, section: 0)) as? TestObject
        XCTAssert(object?.value == "1")
        object = controller.object(at: IndexPath(row: 1, section: 0)) as? TestObject
        XCTAssert(object?.value == "2")
        object = controller.object(at: IndexPath(row: 2, section: 0)) as? TestObject
        XCTAssert(object?.value == "3")


        controller.startUpdating()
        controller.reloadObject(at: 0)
        controller.reloadObject(at: 1)
        controller.reloadObject(at: 2)
        controller.endUpdating()

        XCTAssert(delegate.itemChanges.count == 3)
        XCTAssert(delegate.itemChanges[0].type == .update)
        XCTAssert(delegate.itemChanges[1].type == .update)
        XCTAssert(delegate.itemChanges[2].type == .update)

        XCTAssert(controller.numberOfSections() == 1)
        XCTAssert(controller.numberOfItems(inSection: 0) == 3)

        object = controller.object(at: IndexPath(row: 0, section: 0)) as? TestObject
        XCTAssert(object?.value == "1")
        object = controller.object(at: IndexPath(row: 1, section: 0)) as? TestObject
        XCTAssert(object?.value == "2")
        object = controller.object(at: IndexPath(row: 2, section: 0)) as? TestObject
        XCTAssert(object?.value == "3")


        array[0].section = "1"
        array[1].section = "2"
        array[2].section = "3"

        controller.startUpdating()
        controller.reloadObject(at: 2)
        controller.reloadObject(at: 0)
        controller.reloadObject(at: 1)
        controller.endUpdating()

        XCTAssert(delegate.itemChanges.count == 3)

        XCTAssert(controller.numberOfSections() == 3)
        XCTAssert(controller.numberOfItems(inSection: 0) == 1)
        XCTAssert(controller.numberOfItems(inSection: 1) == 1)
        XCTAssert(controller.numberOfItems(inSection: 2) == 1)

        object = controller.object(at: IndexPath(row: 0, section: 0)) as? TestObject
        XCTAssert(object?.value == "1")
        object = controller.object(at: IndexPath(row: 0, section: 1)) as? TestObject
        XCTAssert(object?.value == "2")
        object = controller.object(at: IndexPath(row: 0, section: 2)) as? TestObject
        XCTAssert(object?.value == "3")
    }

    func testReloadObjectNoChangesDifferentSection111() {
        let delegate = TestDelegate()
        let controller = DPSectionedArrayController(delegate: delegate, sectionHashCalculator: TestObject.sectionHash, sectionSortDescriptor: TestObject.sectionSort)

        let array = [TestObject(section: "1", value: "1"), TestObject(section: "2", value: "2"), TestObject(section: "3", value: "3")]
        controller.setObjects(array)

        XCTAssert(controller.numberOfSections() == 3)
        XCTAssert(controller.numberOfItems(inSection: 0) == 1)
        XCTAssert(controller.numberOfItems(inSection: 1) == 1)
        XCTAssert(controller.numberOfItems(inSection: 2) == 1)

        var object = controller.object(at: IndexPath(row: 0, section: 0)) as? TestObject
        XCTAssert(object?.value == "1")
        object = controller.object(at: IndexPath(row: 0, section: 1)) as? TestObject
        XCTAssert(object?.value == "2")
        object = controller.object(at: IndexPath(row: 0, section: 2)) as? TestObject
        XCTAssert(object?.value == "3")


        controller.startUpdating()
        controller.reloadObject(at: 0)
        controller.reloadObject(at: 1)
        controller.reloadObject(at: 2)
        controller.endUpdating()

        XCTAssert(delegate.itemChanges.count == 3)
        XCTAssert(delegate.itemChanges[0].type == .update)
        XCTAssert(delegate.itemChanges[1].type == .update)
        XCTAssert(delegate.itemChanges[2].type == .update)

        XCTAssert(controller.numberOfSections() == 3)
        XCTAssert(controller.numberOfItems(inSection: 0) == 1)
        XCTAssert(controller.numberOfItems(inSection: 1) == 1)
        XCTAssert(controller.numberOfItems(inSection: 2) == 1)

        object = controller.object(at: IndexPath(row: 0, section: 0)) as? TestObject
        XCTAssert(object?.value == "1")
        object = controller.object(at: IndexPath(row: 0, section: 1)) as? TestObject
        XCTAssert(object?.value == "2")
        object = controller.object(at: IndexPath(row: 0, section: 2)) as? TestObject
        XCTAssert(object?.value == "3")


        array[0].section = "1"
        array[1].section = "1"
        array[2].section = "1"

        controller.startUpdating()
        controller.reloadObject(at: 2)
        controller.reloadObject(at: 0)
        controller.reloadObject(at: 1)
        controller.endUpdating()

        XCTAssert(delegate.itemChanges.count == 3)

        XCTAssert(controller.numberOfSections() == 1)
        XCTAssert(controller.numberOfItems(inSection: 0) == 3)

        object = controller.object(at: IndexPath(row: 0, section: 0)) as? TestObject
        XCTAssert(object?.value == "1")
        object = controller.object(at: IndexPath(row: 1, section: 0)) as? TestObject
        XCTAssert(object?.value == "2")
        object = controller.object(at: IndexPath(row: 2, section: 0)) as? TestObject
        XCTAssert(object?.value == "3")
    }

    func testMixedChanges() {
        let delegate = TestDelegate()
        let controller = DPSectionedArrayController(delegate: delegate, sectionHashCalculator: TestObject.sectionHash, sectionSortDescriptor: TestObject.sectionSort)

        let array = [TestObject(section: "1", value: "1"), TestObject(section: "2", value: "2"), TestObject(section: "3", value: "3")]
        controller.setObjects(array)

        array[0].section = "0"
        array[0].value = "0"

        controller.startUpdating()
        controller.removeObject(at: 1)
        controller.insert(TestObject(section: "1", value: "n1"), at: 0)
        controller.reloadObject(at: 0)
        controller.reloadObject(at: 2)
        controller.endUpdating()

        XCTAssert(delegate.itemChanges.count == 4)

        XCTAssert(controller.numberOfSections() == 3)
        XCTAssert(controller.numberOfItems(inSection: 0) == 1)
        XCTAssert(controller.numberOfItems(inSection: 1) == 1)
        XCTAssert(controller.numberOfItems(inSection: 2) == 1)


        var object = controller.object(at: IndexPath(row: 0, section: 0)) as? TestObject
        XCTAssert(object?.value == "0")
        object = controller.object(at: IndexPath(row: 0, section: 1)) as? TestObject
        XCTAssert(object?.value == "n1")
        object = controller.object(at: IndexPath(row: 0, section: 2)) as? TestObject
        XCTAssert(object?.value == "3")
    }
}
