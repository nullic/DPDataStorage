//
//  DPDataSourceContainer.h
//  DPDataStorageDemo
//
//  Created by Alex Bakhtin on 10/7/15.
//  Copyright © 2015 dmitriy.petrusevich. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DataSourceContainerController;

@protocol DataSourceContainerControllerDelegate <NSObject>
@optional
- (void)controller:(id<DataSourceContainerController>)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath;
@optional
- (void)controller:(id<DataSourceContainerController>)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type;
@optional
- (void)controllerWillChangeContent:(id<DataSourceContainerController>)controller;
@optional
- (void)controllerDidChangeContent:(id<DataSourceContainerController>)controller;
@end

@protocol DataSourceContainerController <NSObject>
@property (nonatomic, weak) id<DataSourceContainerControllerDelegate> delegate;
@property (nonatomic, readonly) NSArray<id<NSFetchedResultsSectionInfo>> * sections;
@property (nonatomic, readonly) BOOL hasData;
@property (nonatomic, readonly) NSArray *fetchedObjects;

- (id _Nonnull)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath * _Nullable)indexPathForObject:(id)object;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
@end

NS_ASSUME_NONNULL_END
