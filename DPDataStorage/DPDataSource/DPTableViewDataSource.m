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
@end

@implementation DPTableViewDataSource

- (void)setTableView:(UITableView *)tableView {
    if (_tableView != tableView) {
        _tableView = tableView;
        [_tableView reloadData];
        [self showNoDataViewIfNeeded];
    }
}

- (void)setCellIdentifier:(NSString *)cellIdentifier {
    _cellIdentifier = [cellIdentifier copy];
    [self.tableView reloadData];
    [self showNoDataViewIfNeeded];
}

- (void)setListController:(id<DataSourceContainerController>)listController {
    [super setListController:listController];
    [self.tableView reloadData];
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

- (instancetype)initWithTableView:(UITableView *)tableView listController:(id<DataSourceContainerController>)listController forwardDelegate:(id)forwardDelegate cellIdentifier:(NSString *)cellIdentifier {
    if ((self = [super init])) {
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

#pragma mark - NoData view

- (void)showNoDataViewIfNeeded {
    [self setNoDataViewHidden:[self hasData]];
}

- (void)setNoDataViewHidden:(BOOL)hidden {
    if (self.noDataView == nil || self.tableView == nil) return;

    if (self.noDataView.superview == nil && hidden == NO) {
        self.noDataView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.noDataView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.tableView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.noDataView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.tableView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.noDataView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.tableView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.noDataView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.tableView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];

        if (self.tableView.backgroundView) {
            [self.tableView.backgroundView addSubview:self.noDataView];
        }
        else {
            self.tableView.backgroundView = self.noDataView;
        }

        [self.tableView addConstraints:@[width, height, centerX, centerY]];
    }
    else if (self.noDataView.superview != nil && hidden == YES) {
        if (self.tableView.backgroundView == self.noDataView) {
            self.tableView.backgroundView = nil;
        }
        else {
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (controller == self.listController) {
        self.updatesBlocks = (self.disableAnimations == NO) ? [NSMutableArray array] : nil;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (controller == self.listController && self.tableView.dataSource != nil) {
        if (self.updatesBlocks.count > 0 && self.tableView.window) {
            [self.tableView beginUpdates];
            for (dispatch_block_t updates in self.updatesBlocks) {
                updates();
            }
            [self.tableView endUpdates];
            self.updatesBlocks = nil;
        }
        else {
            [self.tableView reloadData];
        }

        [self showNoDataViewIfNeeded];
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
                    [tv insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    break;

                case NSFetchedResultsChangeDelete:
                    [tv deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    break;

                case NSFetchedResultsChangeUpdate:
                    [tv reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    break;

                case NSFetchedResultsChangeMove:
                    if ([newIndexPath isEqual:indexPath] == NO) {
                        [tv moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
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
                    [tv insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                    break;
                case NSFetchedResultsChangeDelete:
                    [tv deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                    break;
                case NSFetchedResultsChangeUpdate:
                    [tv reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
                    break;
                default:
                    break;
            }
        };
        [self.updatesBlocks addObject:[block copy]];
    }
}

@end
