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
- (void)controller:(id<DataSourceContainerController>)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;
@optional
- (void)controller:(id<DataSourceContainerController>)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type;
@optional
- (void)controllerWillChangeContent:(id<DataSourceContainerController>)controller;
@optional
- (void)controllerDidChangeContent:(id<DataSourceContainerController>)controller;
@end

@protocol DataSourceContainerController <NSObject>
@property (nonatomic, weak) id<DataSourceContainerControllerDelegate> delegate;
@property (nonatomic, readonly) NSArray *sections; // @[<NSFetchedResultsSectionInfo>]

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;
@end

@interface NSFetchedResultsController (CommonFetchedResultsController) <DataSourceContainerController>
@end
