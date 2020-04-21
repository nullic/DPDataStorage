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
@property (nonatomic, strong) NSMutableArray *updatesFinishBlocks;
@property (nonatomic, strong) NSMutableArray *selectedObjects;
@property (nonatomic, strong) id visibleObject;
@property (nonatomic, assign) CGFloat visibleObjectShift;
@end

@implementation DPCollectionViewDataSource

- (void)setCollectionView:(UICollectionView *)collectionView {
    if (_collectionView != collectionView) {
        _collectionView = collectionView;
        [_collectionView reloadData];
        [self invalidateNoDataView];
    }
}

- (void)setCellIdentifier:(NSString *)cellIdentifier {
    _cellIdentifier = [cellIdentifier copy];
    [self.collectionView reloadData];
    [self invalidateNoDataView];
}

- (void)setListController:(id<DataSourceContainerController>)listController {
    [super setListController:listController];
    [self.collectionView reloadData];
    [self invalidateNoDataView];
}

- (void)setNoDataView:(UIView *)noDataView {
    if (_noDataView != noDataView) {
        if (self.collectionView.backgroundView == _noDataView) {
            self.collectionView.backgroundView = nil;
        }
        else {
            [_noDataView removeFromSuperview];
        }
        _noDataView = noDataView;
        [self invalidateNoDataView];
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

- (void)invalidateNoDataView {
    [self setNoDataViewHidden:[self hasData]];
}

- (void)setNoDataViewHidden:(BOOL)hidden {
    if (self.noDataView == nil || self.collectionView == nil) return;

    if (self.noDataView.superview == nil && hidden == NO) {
        self.collectionView.bounces = NO;

        self.noDataView.translatesAutoresizingMaskIntoConstraints = YES;
        self.noDataView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        if (self.collectionView.backgroundView) {
            self.noDataView.frame = self.collectionView.backgroundView.bounds;
            [self.collectionView.backgroundView addSubview:self.noDataView];
        } else {
            self.noDataView.frame = self.collectionView.bounds;
            self.collectionView.backgroundView = self.noDataView;
        }
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

- (void)addCollectionViewUpdateBlock:(dispatch_block_t)block {
    NSAssert(self.updatesBlocks != nil, @"Animation disabled or -[controllerWillChangeContent:] not called");
    [self.updatesBlocks addObject:[block copy]];
}

- (void)addCollectionViewUpdateFinishBlock:(dispatch_block_t _Nonnull)block {
    if (self.updatesFinishBlocks == nil) {
        self.updatesFinishBlocks = [NSMutableArray array];
    }
    [self.updatesFinishBlocks addObject:[block copy]];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (controller == self.listController) {
        self.updatesBlocks = (self.disableAnimations == NO) ? [NSMutableArray array] : nil;
    }
    
    if (self.preserveSelection == YES) {
        self.selectedObjects = [NSMutableArray array];
        for (NSIndexPath *ip in [self.collectionView indexPathsForSelectedItems]) {
            [self.selectedObjects addObject:[self objectAtIndexPath:ip]];
        }
    }

    if (self.preservePosition == YES) {
        NSIndexPath *ip = [[[self.collectionView indexPathsForVisibleItems] sortedArrayUsingSelector: @selector(compare:)] firstObject];
        if (ip != nil) {
            UICollectionViewLayoutAttributes *atts = [self.collectionView layoutAttributesForItemAtIndexPath:ip];
            self.visibleObject = [self objectAtIndexPath:ip];
            self.visibleObjectShift = self.collectionView.contentOffset.y - atts.frame.origin.y;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (controller == self.listController && self.collectionView.dataSource != nil) {
        if (self.disableAnimations == NO && self.updatesBlocks.count > 0 && self.collectionView.window) {
            NSArray *blocks = self.updatesBlocks;
            self.updatesBlocks = nil;

            dispatch_block_t updateBlock = ^{
                [self.collectionView performBatchUpdates:^{
                    for (dispatch_block_t updates in blocks) { updates(); }
                } completion:^(BOOL finished) {
                    for (dispatch_block_t block in self.updatesFinishBlocks) { block(); }
                }];
            };

            if (self.preservePosition == YES) {
                [UIView performWithoutAnimation:^{
                    updateBlock();
                }];
            } else {
                updateBlock();
            }
        }
        else {
            [self.collectionView reloadData];
            self.updatesBlocks = nil;
            for (dispatch_block_t block in self.updatesFinishBlocks) { block(); }
        }
        [self invalidateNoDataView];

        if (self.preserveSelection == YES) {
            for (id object in self.selectedObjects) {
                NSIndexPath *ip = [self indexPathForObject:object];
                if (ip != nil){
                     [self.collectionView selectItemAtIndexPath:ip animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                }
            }
        }

        if (self.preservePosition == YES && self.visibleObject != nil) {
            NSIndexPath *ip = [self indexPathForObject:self.visibleObject];
            if (ip != nil) {
                [self.collectionView layoutIfNeeded];
                UICollectionViewLayoutAttributes *atts = [self.collectionView layoutAttributesForItemAtIndexPath:ip];
                CGFloat y = self.visibleObjectShift + atts.frame.origin.y;
                [self.collectionView setContentOffset:CGPointMake(0, y) animated:false];
            }
        }

        self.selectedObjects = nil;
        self.visibleObject = nil;
        self.updatesFinishBlocks = nil;
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
                        [cv deleteItemsAtIndexPaths:@[indexPath]];
                        [cv insertItemsAtIndexPaths:@[newIndexPath]];
//                        [cv moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
                    }
                    else {
                         [cv reloadItemsAtIndexPaths:@[indexPath]];
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
