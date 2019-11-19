//
//  DPTableViewDataSource.m
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 17/03/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "DPTableViewDataSource.h"

@interface DPTableViewDataSource ()
@property (nonatomic, strong) NSMutableArray *updatesBlocks;
@property (nonatomic, strong) NSMutableArray *selectedObjects;
@property (nonatomic, strong) id visibleObject;
@property (nonatomic, assign) CGFloat visibleObjectShift;
@end

@implementation DPTableViewDataSource

- (void)setTableView:(UITableView *)tableView {
    if (_tableView != tableView) {
        _tableView = tableView;
        [_tableView reloadData];
        [self invalidateNoDataView];
    }
}

- (void)setCellIdentifier:(NSString *)cellIdentifier {
    _cellIdentifier = [cellIdentifier copy];
    [self.tableView reloadData];
    [self invalidateNoDataView];
}

- (void)setListController:(id<DataSourceContainerController>)listController {
    [super setListController:listController];
    [self.tableView reloadData];
    [self invalidateNoDataView];
}

- (void)setNoDataView:(UIView *)noDataView {
    if (_noDataView != noDataView) {
        [_noDataView removeFromSuperview];
        _noDataView = noDataView;
        [self invalidateNoDataView];
    }
}

- (void)setDisableBouncingIfNoDataPresented:(BOOL)disableBouncingIfNoDataPresented {
    _disableBouncingIfNoDataPresented = disableBouncingIfNoDataPresented;
    [self invalidateNoDataView];
}

#pragma mark - Init

- (instancetype)init {
    if ((self = [super init])) {
        self.insertAnimation = UITableViewRowAnimationAutomatic;
        self.deleteAnimation = UITableViewRowAnimationAutomatic;
        self.updateAnimation = UITableViewRowAnimationNone;

        self.sectionInsertAnimation = UITableViewRowAnimationAutomatic;
        self.sectionDeleteAnimation = UITableViewRowAnimationAutomatic;
        self.sectionUpdateAnimation = UITableViewRowAnimationNone;

        self.disableBouncingIfNoDataPresented = YES;
    }
    return self;
}

- (instancetype)initWithTableView:(UITableView *)tableView listController:(id<DataSourceContainerController>)listController forwardDelegate:(id)forwardDelegate cellIdentifier:(NSString *)cellIdentifier {
    if ((self = [self init])) {
        self.cellIdentifier = cellIdentifier;

        self.forwardDelegate = forwardDelegate;
        self.listController = listController;
        self.listController.delegate = self;

        tableView.dataSource = self;
        tableView.delegate = self;
        self.tableView = tableView;
    }

    return self;
}

- (void)dealloc {
    if (self.tableView.delegate == self) self.tableView.delegate = nil;
    if (self.tableView.dataSource == self) self.tableView.dataSource = nil;
}

#pragma mark - NoData view

- (void)invalidateNoDataView {
    [self setNoDataViewHidden:[self hasData]];
}

- (void)setNoDataViewHidden:(BOOL)noDataViewHidden {
    if (self.noDataView == nil || self.tableView == nil) return;

    self.tableView.bounces = noDataViewHidden || self.disableBouncingIfNoDataPresented == NO;

    if (self.noDataView.superview != nil && self.noDataView.superview != self.tableView.backgroundView && self.noDataView != self.tableView.backgroundView) {
        // If 'no data view' can not be used or be added to table view background view
        // it should be added to any other view in storyboard or mannually
        // and data source will handle its visibility based on table view data presenting
        self.noDataView.hidden = noDataViewHidden;
        [self.noDataView.superview bringSubviewToFront:self.noDataView];
    } else if (self.noDataView.superview == nil && noDataViewHidden == NO) {
        self.noDataView.translatesAutoresizingMaskIntoConstraints = YES;
        self.noDataView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        if (self.tableView.backgroundView) {
            self.noDataView.frame = self.tableView.backgroundView.bounds;
            [self.tableView.backgroundView addSubview:self.noDataView];
        } else {
            self.noDataView.frame = self.tableView.bounds;
            self.tableView.backgroundView = self.noDataView;
        }
    } else if (self.noDataView.superview != nil && noDataViewHidden == YES) {
        if (self.tableView.backgroundView == self.noDataView) {
            self.tableView.backgroundView = nil;
        } else {
            [self.noDataView removeFromSuperview];
        }
    }
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
        cell = [(id<UITableViewDataSource>)self.forwardDelegate tableView:tableView cellForRowAtIndexPath:indexPath];
    }

    if (cell == nil) {
        UITableViewCell<DPDataSourceCell> *frc_cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
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

- (void)addTableViewUpdateBlock:(dispatch_block_t)block {
    NSAssert(self.updatesBlocks != nil, @"Animation disabled or -[controllerWillChangeContent:] not called");
    [self.updatesBlocks addObject:[block copy]];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (controller == self.listController) {
        self.updatesBlocks = (self.disableAnimations == NO) ? [NSMutableArray array] : nil;
    }

    if (self.preserveSelection == YES) {
        self.selectedObjects = [NSMutableArray array];
        for (NSIndexPath *ip in [self.tableView indexPathsForSelectedRows]) {
            [self.selectedObjects addObject:[self objectAtIndexPath:ip]];
        }
    }

    if (self.preservePosition == YES) {
        NSIndexPath *ip = [[[self.tableView indexPathsForVisibleRows] sortedArrayUsingSelector: @selector(compare:)] firstObject];
        if (ip != nil) {
            CGRect rect = [self.tableView rectForRowAtIndexPath:ip];
            self.visibleObject = [self objectAtIndexPath:ip];
            self.visibleObjectShift = self.tableView.contentOffset.y - rect.origin.y;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (controller == self.listController && self.tableView.dataSource != nil) {
        if (self.disableAnimations == NO && self.updatesBlocks.count > 0 && self.tableView.window) {
            dispatch_block_t updateBlock = ^{
                [self.tableView beginUpdates];
                for (dispatch_block_t updates in self.updatesBlocks) {
                    updates();
                }
                [self.tableView endUpdates];
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
            [self.tableView reloadData];
        }

        self.updatesBlocks = nil;
        [self invalidateNoDataView];

        if (self.preserveSelection == YES) {
            for (id object in self.selectedObjects) {
                NSIndexPath *ip = [self indexPathForObject:object];
                if (ip != nil) [self.tableView selectRowAtIndexPath:ip animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }

        if (self.preservePosition == YES && self.visibleObject != nil) {
            NSIndexPath *ip = [self indexPathForObject:self.visibleObject];
            if (ip != nil) {
                [self.tableView layoutIfNeeded];
                CGRect rect = [self.tableView rectForRowAtIndexPath:ip];
                CGFloat y = self.visibleObjectShift + rect.origin.y;
                [self.tableView setContentOffset:CGPointMake(0, y) animated:false];
            }
        }

        self.selectedObjects = nil;
        self.visibleObject = nil;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (controller == self.listController && self.updatesBlocks) {
        UITableView *tv = self.tableView;

        dispatch_block_t block = ^{
            switch(type) {
                case NSFetchedResultsChangeInsert:
                    [tv insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:self.insertAnimation];
                    break;

                case NSFetchedResultsChangeDelete:
                    [tv deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:self.deleteAnimation];
                    break;

                case NSFetchedResultsChangeUpdate:
                    [tv reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:self.updateAnimation];
                    break;

                case NSFetchedResultsChangeMove:
                    if ([newIndexPath isEqual:indexPath] == NO) {
                        [tv moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
                    }
                    else {
                        [tv reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:self.updateAnimation];
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
        UITableView *tv = self.tableView;

        dispatch_block_t block = ^{
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    [tv insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:self.sectionInsertAnimation];
                    break;
                case NSFetchedResultsChangeDelete:
                    [tv deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:self.sectionDeleteAnimation];
                    break;
                case NSFetchedResultsChangeUpdate:
                    [tv reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:self.sectionUpdateAnimation];
                    break;
                default:
                    break;
            }
        };
        [self.updatesBlocks addObject:[block copy]];
    }
}

@end
