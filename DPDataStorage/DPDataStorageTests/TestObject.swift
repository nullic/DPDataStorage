//
//  TestObject.swift
//  DPDataStorageTests
//
//  Created by Dmitriy Petrusevich on 5/4/19.
//  Copyright © 2019 dmitriy.petrusevich. All rights reserved.
//

import Foundation

class TestObject: NSObject {
    @objc var section: String
    @objc var value: String

    init(section: String, value: String) {
        self.section = section
        self.value = value
        super.init()
    }

    override var description: String {
        return "\(super.description) {section: \(section); value: \(value)}"
    }

    static var sectionSort: NSSortDescriptor = NSSortDescriptor(key: #keyPath(TestObject.section), ascending: true)
}
