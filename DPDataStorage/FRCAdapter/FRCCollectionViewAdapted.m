//
//  FRCCollectionVeiwAdapted.m
//  Commentator
//
//  Created by Dmitriy Petrusevich on 28/04/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "FRCCollectionViewAdapted.h"

@interface FRCCollectionViewAdapted ()
@property (nonatomic, strong) NSMutableArray *updatesBlocks;
@end

@implementation FRCCollectionViewAdapted

- (void)setCollectionView:(UICollectionView *)collectionView {
    if (_collectionView != collectionView) {
        _collectionView = collectionView;
        [_collectionView reloadData];
    }
}

- (void)setCellIdentifier:(NSString *)cellIdentifier {
    _cellIdentifier = [cellIdentifier copy];
    [self.collectionView reloadData];
}

- (void)setListController:(id<CommonFetchedResultsController>)listController {
    [super setListController:listController];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if ([self.forwardDelegate respondsToSelector:@selector(collectionView:cellForItemAtIndexPath:)]) {
        cell = [(id<UICollectionViewDataSource>)self.forwardDelegate collectionView:collectionView cellForItemAtIndexPath:indexPath];
    }

    if (cell == nil) {
        UICollectionViewCell<FRCAdaptedCell> *frc_cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
        if ([frc_cell conformsToProtocol:@protocol(FRCAdaptedCell)]) {
            id object = [self objectAtIndexPath:indexPath];
            [frc_cell configureWithObject:object];
            cell = frc_cell;
        }
        else {
            NSString *reason = [NSString stringWithFormat:@"Type '%@' does not conform to protocol '%@'", NSStringFromClass([frc_cell class]), NSStringFromProtocol(@protocol(FRCAdaptedCell))];
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
        }
    }
    
    return cell;
}

#pragma mark - NSFetchedResultsController

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (controller == self.listController) {
        self.updatesBlocks = (self.disableAnimations == NO) ? [NSMutableArray array] : nil;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (controller == self.listController && self.collectionView.dataSource != nil) {
        if (self.updatesBlocks.count > 0) {
            NSArray *blocks = self.updatesBlocks;
            self.updatesBlocks = nil;

            [self.collectionView performBatchUpdates:^{
                for (dispatch_block_t updates in blocks) {
                    updates();
                }
            } completion:nil];
        }
        else {
            [self.collectionView reloadData];
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (controller == self.listController && self.updatesBlocks) {
        UICollectionView *cv = self.collectionView;

        dispatch_block_t block = ^{
            switch(type) {
                case NSFetchedResultsChangeInsert:
                    [cv insertItemsAtIndexPaths:@[newIndexPath]];
                    break;

                case NSFetchedResultsChangeDelete:
                    [cv deleteItemsAtIndexPaths:@[indexPath]];
                    break;

                case NSFetchedResultsChangeUpdate:
                    [cv reloadItemsAtIndexPaths:@[indexPath]];
                    break;

                case NSFetchedResultsChangeMove:
                    if ([newIndexPath isEqual:indexPath] == NO) {
                        [cv moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
                    }
                    break;
                    
            }
        };
        [self.updatesBlocks addObject:[block copy]];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (controller == self.listController && self.updatesBlocks) {
        UICollectionView *cv = self.collectionView;

        dispatch_block_t block = ^{
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    [cv insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                    break;
                case NSFetchedResultsChangeDelete:
                    [cv deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                    break;
                default:
                    break;
            }
        };
        [self.updatesBlocks addObject:[block copy]];
    }
}

@end
