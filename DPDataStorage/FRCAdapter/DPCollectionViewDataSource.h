//
//  DPCollectionViewDataSource.h
//  Commentator
//
//  Created by Dmitriy Petrusevich on 28/04/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPBaseDataSource.h"
#import "DPDataSourceCell.h"

@interface DPCollectionViewDataSource : DPBaseDataSource <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, copy) IBInspectable NSString *cellIdentifier; // Cell must conform <DPDataSourceCell>
@property (nonatomic) IBInspectable BOOL disableAnimations;

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
@end
