//
//  DPArrayController.H
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 23/07/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "DPBaseDataSource.h"

@interface DPArrayController : NSObject <DataSourceContainerController>
@property (nonatomic, weak) id<DataSourceContainerControllerDelegate> delegate;
@property (nonatomic, assign) BOOL removeEmptySectionsAutomaticaly; // Default YES
@property (nonatomic, strong) NSPredicate *filter;

- (instancetype)initWithDelegate:(id<DataSourceContainerControllerDelegate>)delegate;

- (void)removeAllObjects;

- (void)insertObject:(id)object atIndextPath:(NSIndexPath *)indexPath;
- (void)deleteObjectAtIndextPath:(NSIndexPath *)indexPath;
- (void)reloadObjectAtIndextPath:(NSIndexPath *)indexPath;
- (void)moveObjectAtIndextPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)insertSectionAtIndex:(NSUInteger)index;
- (void)removeSectionAtIndex:(NSUInteger)index;
- (void)removeEmptySections;

- (void)addObjects:(NSArray *)objects atSection:(NSInteger)section;
- (void)setObjects:(NSArray *)objects atSection:(NSInteger)section;

- (void)startUpdating;
- (void)endUpdating;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;
@end
