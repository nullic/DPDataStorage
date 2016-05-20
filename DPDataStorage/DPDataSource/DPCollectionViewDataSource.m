//
//  DPCollectionViewDataSource.m
//  Commentator
//
//  Created by Dmitriy Petrusevich on 28/04/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "DPCollectionViewDataSource.h"

@interface DPCollectionViewDataSource ()
@property (nonatomic, strong) NSMutableArray *updatesBlocks;
@end

@implementation DPCollectionViewDataSource

- (void)setCollectionView:(UICollectionView *)collectionView {
    if (_collectionView != collectionView) {
        _collectionView = collectionView;
        [_collectionView reloadData];
        [self showNoDataViewIfNeeded];
    }
}

- (void)setCellIdentifier:(NSString *)cellIdentifier {
    _cellIdentifier = [cellIdentifier copy];
    [self.collectionView reloadData];
    [self showNoDataViewIfNeeded];
}

- (void)setListController:(id<DataSourceContainerController>)listController {
    [super setListController:listController];
    [self.collectionView reloadData];
    [self showNoDataViewIfNeeded];
}

- (void)setNoDataView:(UIView *)noDataView {
    if (_noDataView != noDataView) {
        [_noDataView removeFromSuperview];
        _noDataView = noDataView;
        [self showNoDataViewIfNeeded];
    }
}

#pragma mark - Init

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView listController:(id<DataSourceContainerController>)listController forwardDelegate:(id)forwardDelegate cellIdentifier:(NSString *)cellIdentifier {
    if ((self = [super init])) {
        self.cellIdentifier = cellIdentifier;

        self.forwardDelegate = forwardDelegate;
        self.listController = listController;
        self.listController.delegate = self;

        collectionView.dataSource = self;
        collectionView.delegate = self;
        self.collectionView = collectionView;

    }

    return self;
}

- (void)dealloc {
    if (self.collectionView.delegate == self) self.collectionView.delegate = nil;
    if (self.collectionView.dataSource == self) self.collectionView.dataSource = nil;
}

#pragma mark - NoData view

- (void)showNoDataViewIfNeeded {
    [self setNoDataViewHidden:[self hasData]];
}

- (void)setNoDataViewHidden:(BOOL)hidden {
    if (self.noDataView == nil || self.collectionView == nil) return;

    if (self.noDataView.superview == nil && hidden == NO) {
        self.collectionView.bounces = NO;

        self.noDataView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.noDataView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.noDataView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.noDataView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.noDataView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];

        if (self.collectionView.backgroundView) {
            [self.collectionView.backgroundView addSubview:self.noDataView];
        }
        else {
            self.collectionView.backgroundView = self.noDataView;
        }

        [self.collectionView addConstraints:@[width, height, centerX, centerY]];
    }
    else if (self.noDataView.superview != nil && hidden == YES) {
        self.collectionView.bounces = YES;

        if (self.collectionView.backgroundView == self.noDataView) {
            self.collectionView.backgroundView = nil;
        }
        else {
            [self.noDataView removeFromSuperview];
        }
    }
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
        UICollectionViewCell<DPDataSourceCell> *frc_cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
        if ([frc_cell conformsToProtocol:@protocol(DPDataSourceCell)]) {
            id object = [self objectAtIndexPath:indexPath];
            [frc_cell configureWithObject:object];
            cell = frc_cell;
        }
        else {
            NSString *reason = [NSString stringWithFormat:@"Type '%@' does not conform to protocol '%@'", NSStringFromClass([frc_cell class]), NSStringFromProtocol(@protocol(DPDataSourceCell))];
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
        if (self.updatesBlocks.count > 0 && self.collectionView.window) {
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

        [self showNoDataViewIfNeeded];
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
                case NSFetchedResultsChangeUpdate:
                    [cv reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                    break;
                default:
                    break;
            }
        };
        [self.updatesBlocks addObject:[block copy]];
    }
}

@end
