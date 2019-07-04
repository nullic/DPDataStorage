//
//  Utils.swift
//  DPDataStorageTests
//
//  Created by Dmitriy Petrusevich on 5/11/19.
//  Copyright © 2019 dmitriy.petrusevich. All rights reserved.
//

import Foundation
import DPDataStorage

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
