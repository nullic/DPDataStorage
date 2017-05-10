//
//  DPCollectionViewDataSource.h
//  Commentator
//
//  Created by Dmitriy Petrusevich on 28/04/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "DPBaseDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface DPCollectionViewDataSource : DPBaseDataSource <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak, nullable) IBOutlet UICollectionView *collectionView;

- (instancetype _Nonnull)initWithCollectionView:(UICollectionView * _Nullable)collectionView listController:(id<DataSourceContainerController> _Nullable)listController forwardDelegate:(id _Nullable)forwardDelegate cellIdentifier:(NSString * _Nullable)cellIdentifier;

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView * _Nullable)collectionView;
- (NSInteger)collectionView:(UICollectionView * _Nullable)collectionView numberOfItemsInSection:(NSInteger)section;
- (UICollectionViewCell * _Nonnull)collectionView:(UICollectionView * _Nullable)collectionView cellForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
@end

NS_ASSUME_NONNULL_END
