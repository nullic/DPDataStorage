//
//  CollectionViewDataSource.swift
//  DPDataStorage
//
//  Created by Alex on 12/19/17.
//  Copyright © 2017 EffectiveSoft. All rights reserved.
//

import UIKit

protocol CollectionViewDataSourceDelegate: class {
    func dataSource(_ dataSource: DataSourceProtocol, cellIdentifierFor object: Any, at indexPath: IndexPath) -> String?
    func dataSource(_ dataSource: DataSourceProtocol, didSelect object:Any, at indexPath: IndexPath)
    func dataSource(_ dataSource: DataSourceProtocol, willDispaly cell:DataSourceConfigurable, for object:Any, at indexPath: IndexPath)
}

extension CollectionViewDataSourceDelegate {
    func dataSource(_ dataSource: DataSourceProtocol, cellIdentifierFor object: Any, at indexPath: IndexPath) -> String? {
        return nil
    }
    func dataSource(_ dataSource: DataSourceProtocol, didSelect object:Any, at indexPath: IndexPath) { }
    func dataSource(_ dataSource: DataSourceProtocol, willDispaly cell:DataSourceConfigurable, for object:Any, at indexPath: IndexPath) {
        
    }
}

class CollectionViewDataSource<ObjectType>: DataSource<ObjectType>, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet public weak var collectionView: UICollectionView?
    @IBInspectable public var cellIdentifier: String?
    public weak var delegate: CollectionViewDataSourceDelegate?

    public init(collectionView: UICollectionView,
                container: DataSourceContainer<ObjectType>,
                delegate: CollectionViewDataSourceDelegate?,
                cellIdentifier: String?) {
        self.collectionView = collectionView
        self.delegate = delegate
        self.cellIdentifier = cellIdentifier
        super.init(container: container)
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let container = container, let numberOfSections = container.numberOfSections() else {
            return 0
        }
        return numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let container = container, let numberOfItems = container.numberOfItems(in: section) else {
            return 0
        }
        return numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cellIdentifier: String? = nil
        if let delegateCellIdentifier = delegate?.dataSource(self, cellIdentifierFor: object, at: indexPath) {
            cellIdentifier = delegateCellIdentifier
        }
        if cellIdentifier == nil {
            cellIdentifier = self.cellIdentifier
        }
        guard let identifier = cellIdentifier else {
            fatalError("Cell identifier is empty")
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) 
        guard let configurableCell = cell as? DataSourceConfigurable else {
            fatalError("Cell is not implementing DataSourceConfigurable protocol")
        }
        guard let object = container?.object(at: indexPath) else {
            fatalError("Could not retrieve object at \(indexPath)")
        }
        configurableCell.configure(with: object)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let configurableCell = cell as? DataSourceConfigurable,
            let object = container?.object(at: indexPath) else {
                return
        }

        delegate?.dataSource(self, willDispaly: configurableCell, for: object, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let object = container?.object(at: indexPath) as Any? else {
            fatalError("Object non exists")
        }
        self.delegate?.dataSource(self, didSelect: object, at: indexPath)
    }
}

