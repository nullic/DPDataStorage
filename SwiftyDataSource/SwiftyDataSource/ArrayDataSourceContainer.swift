//
//  ArrayController.swift
//  DPDataStorage
//
//  Created by Aleksey Bakhtin on 12/20/17.
//  Copyright © 2017 EffectiveSoft. All rights reserved.
//

import UIKit

public class ArrayDataSourceContainer<ResultType: Equatable>: DataSourceContainer<ResultType> {

    // MARK: Initializer
    
    init(objects: [ResultType], named: String, delegate: DataSourceContainerDelegate?) {
        super.init(delegate: delegate)
        insert(objects: objects, at: 0, named: named, indexTitle: nil)
    }

    // MARK: DataSourceContainer implementing
    
    open override var sections: [DataSourceSectionInfo]? {
        return arraySections
    }
    
    open override var fetchedObjects: [ResultType]? {
        get {
            return arraySections?.reduce(into: [], { (result, section) in
                if let ojects = section.arrayObjects {
                    result?.append(contentsOf: ojects)
                }
            })
        }
    }
    
    open override func object(at indexPath: IndexPath) -> ResultType? {
        guard let sections = arraySections else { return super.object(at: indexPath); }
        return sections[indexPath.section][indexPath.row]
    }
    
    open override func indexPath(for object: ResultType) -> IndexPath? {
        guard let arraySections = arraySections else { return nil }
        for (sectionIndex, section) in arraySections.enumerated() {
            if let arrayObjects = section.arrayObjects {
                for (objectIndex, arrayObject) in arrayObjects.enumerated() {
                    if (object == arrayObject) {
                        return IndexPath(row: objectIndex, section: sectionIndex)
                    }
                }
            }
        }
        
        return nil
    }
    
    open override func numberOfSections() -> Int? {
        return arraySections?.count
    }
    
    open override func numberOfItems(in section: Int) -> Int? {
        return arraySections?[section].arrayObjects?.count
    }

    // MARK: Array controller public interface
    
    public func insert(objects:[ResultType], at sectionIndex: Int = 0, named name: String = "", indexTitle: String? = nil) {
        let section = Section(objects: objects, name: name, indexTitle: indexTitle)
        self.arraySections?.insert(section, at: sectionIndex)
    }

    public func insert(object:ResultType, at indexPath: IndexPath) {
        let section = arraySections?[indexPath.section]
        if let section = section {
            section.insert(object: object, at: indexPath.row)
        } else {
            self.arraySections?.insert(Section(objects: [object], name: "", indexTitle: nil), at: indexPath.section)
        }
    }

    // MARK: Storage implementing
    
    var arraySections: [Section<ResultType>]?

    // MARK: Additional features

    public var sortDescritor: NSSortDescriptor? {
        didSet {
            // TODO:
        }
    }

    // MARK: Array section class
    
    class Section<ResultType>: DataSourceSectionInfo {
        
        // MARK: Initializing
        
        init(objects: [ResultType]?, name: String, indexTitle: String?) {
            self.arrayObjects = objects
            self.name = name
            self.indexTitle = indexTitle
        }
        
        // MARK: Storage
        
        private(set) var arrayObjects: [ResultType]?
        
        // MARK: DataSourceSectionInfo implementing
        
        public var name: String
        
        public var indexTitle: String?
        
        var numberOfObjects: Int {
            guard let objects = objects else {
                return 0
            }
            return objects.count
        }
        
        public var objects: [Any]? {
            return arrayObjects
        }
        
        // MARK: Public interface
        
        func insert(object: ResultType, at index: Int) {
            self.arrayObjects?.insert(object, at: index)
        }
        
        // MARK: Subscription
        
        subscript(index: Int) -> ResultType? {
            get {
                return arrayObjects?[index]
            }
            set(newValue) {
                if let newValue = newValue {
                    arrayObjects?[index] = newValue
                }
            }
        }
    }
}
