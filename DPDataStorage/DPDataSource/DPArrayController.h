//
//  DPArrayController.H
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 23/07/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "DPBaseDataSource.h"

@class DPChange;

NS_ASSUME_NONNULL_BEGIN

@interface DPArrayController : NSObject <DataSourceContainerController>
@property (nonatomic, weak, nullable) IBOutlet id<DataSourceContainerControllerDelegate> delegate;
@property (nonatomic, readonly) BOOL hasData;

- (instancetype)initWithDelegate:(id<DataSourceContainerControllerDelegate> _Nullable)delegate;
- (void)managedObjectContextObjectsDidChange:(NSNotification *)notification;

- (void)removeAllObjects;
- (void)removeAllObjectsImmediately:(BOOL)immediately;

- (void)insertObject:(id)object atIndextPath:(NSIndexPath *)indexPath;
- (void)insertObject:(id)object atIndextPath:(NSIndexPath *)indexPath immediately:(BOOL)immediately;
- (void)deleteObjectAtIndextPath:(NSIndexPath *)indexPath;
- (void)deleteObjectAtIndextPath:(NSIndexPath *)indexPath immediately:(BOOL)immediately;
- (void)reloadObjectAtIndextPath:(NSIndexPath *)indexPath;
- (void)reloadObjectAtIndextPath:(NSIndexPath *)indexPath immediately:(BOOL)immediately;
- (void)moveObjectAtIndextPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;
- (void)moveObjectAtIndextPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath immediately:(BOOL)immediately;

- (void)insertSectionAtIndex:(NSUInteger)index;
- (void)insertSectionAtIndex:(NSUInteger)index immediately:(BOOL)immediately;
- (void)insertSectionObject:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)index;
- (void)insertSectionObject:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)index immediately:(BOOL)immediately;
- (void)removeSectionAtIndex:(NSUInteger)index;
- (void)removeSectionAtIndex:(NSUInteger)index immediately:(BOOL)immediately;
- (void)reloadSectionAtIndex:(NSUInteger)index;
- (void)reloadSectionAtIndex:(NSUInteger)index immediately:(BOOL)immediately;

- (void)setSectionName:(NSString *)name atIndex:(NSUInteger)index;

- (void)addObjects:(NSArray *)objects atSection:(NSInteger)section;
- (void)addObjects:(NSArray *)objects atSection:(NSInteger)section immediately:(BOOL)immediately;
- (void)setObjects:(NSArray *)objects atSection:(NSInteger)section;
- (void)setObjects:(NSArray *)objects atSection:(NSInteger)section immediately:(BOOL)immediately;

- (void)startUpdating;
- (void)endUpdating;
- (BOOL)isUpdating;

- (BOOL)delegateResponseToDidChangeObject;
- (BOOL)delegateResponseToDidChangeSection;

- (BOOL)hasChanges;
- (NSArray<DPChange *> *)updateChanges;
- (void)applyChanges;
- (void)notifyDelegate;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath * _Nullable)indexPathForObject:(id)object;
@end

NS_ASSUME_NONNULL_END
