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
}

extension CollectionViewDataSourceDelegate {
    func dataSource(_ dataSource: DataSourceProtocol, cellIdentifierFor object: Any, at indexPath: IndexPath) -> String? {
        return nil
    }
}

class CollectionViewDataSource<ObjectType>: NSObject, DataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: Initializer
    
    public init(collectionView: UICollectionView,
                container: DataSourceContainer<ObjectType>,
                delegate: CollectionViewDataSourceDelegate?,
                cellIdentifier: String?) {
        self.collectionView = collectionView
        self.delegate = delegate
        self.cellIdentifier = cellIdentifier
        self.container = container
        super.init()
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
    }

    // MARK: Public properties
    
    public var container: DataSourceContainer<ObjectType>? {
        didSet {
            collectionView?.reloadData()
        }
    }

    public var collectionView: UICollectionView? {
        didSet {
            self.collectionView?.dataSource = self
            self.collectionView?.delegate = self
        }
    }
    
    public var cellIdentifier: String? {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    
    public weak var delegate: CollectionViewDataSourceDelegate?

    // MARK: Implementing of datasource methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let numberOfSections = numberOfSections else {
            return 0
        }
        return numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let numberOfItems = numberOfItems(in: section) else {
            return 0
        }
        return numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let object = object(at: indexPath) else {
            fatalError("Could not retrieve object at \(indexPath)")
        }
        let cellIdentifier = delegate?.dataSource(self, cellIdentifierFor: object, at: indexPath) ?? self.cellIdentifier
        guard let identifier = cellIdentifier else {
            fatalError("Cell identifier is empty")
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) 
        guard let configurableCell = cell as? DataSourceConfigurable else {
            fatalError("Cell is not implementing DataSourceConfigurable protocol")
        }
        configurableCell.configure(with: object)
        return cell
    }
}

