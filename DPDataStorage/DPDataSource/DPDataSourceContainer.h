//
//  DPDataSourceContainer.h
//  DPDataStorageDemo
//
//  Created by Alex Bakhtin on 10/7/15.
//  Copyright © 2015 dmitriy.petrusevich. All rights reserved.
//

@import CoreData;

@protocol DataSourceContainerController;

@protocol DataSourceContainerControllerDelegate <NSObject>
@optional
- (void)controller:(id<DataSourceContainerController> _Nonnull)controller didChangeObject:(id _Nonnull)anObject atIndexPath:(NSIndexPath * _Nullable)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath * _Nullable)newIndexPath;
@optional
- (void)controller:(id<DataSourceContainerController> _Nonnull)controller didChangeSection:(id <NSFetchedResultsSectionInfo> _Nonnull)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type;
@optional
- (void)controllerWillChangeContent:(id<DataSourceContainerController> _Nonnull)controller;
@optional
- (void)controllerDidChangeContent:(id<DataSourceContainerController> _Nonnull)controller;
@end

@protocol DataSourceContainerController <NSObject>
@property (nonatomic, weak) id<DataSourceContainerControllerDelegate> _Nullable delegate;
@property (nonatomic, readonly) NSArray<id<NSFetchedResultsSectionInfo>> * _Nonnull sections;
@property (nonatomic, readonly) BOOL hasData;

- (id _Nonnull)objectAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (NSIndexPath * _Nullable)indexPathForObject:(id _Nonnull)object;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
@end
