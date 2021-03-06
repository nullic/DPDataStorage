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

- (void)insertObject:(id)object atIndextPath:(NSIndexPath *)indexPath;
- (void)deleteObjectAtIndextPath:(NSIndexPath *)indexPath;
- (void)reloadObjectAtIndextPath:(NSIndexPath *)indexPath;
- (void)moveObjectAtIndextPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)insertSectionAtIndex:(NSUInteger)index;
- (void)insertSectionObject:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)index;
- (void)removeSectionAtIndex:(NSUInteger)index;
- (void)reloadSectionAtIndex:(NSUInteger)index;

- (void)setSectionName:(NSString *)name atIndex:(NSUInteger)index;
- (NSString *)sectionNameAtIndex:(NSUInteger)index;

- (void)addObjects:(NSArray *)objects atSection:(NSInteger)section;
- (void)setObjects:(NSArray *)objects atSection:(NSInteger)section;

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
