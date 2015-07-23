//
//  FRCBaseAdapter.h
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 27/04/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import <CoreData/coreData.h>

@protocol CommonFetchedResultsController;

@protocol CommonFetchedResultsControllerDelegate <NSObject>
@optional
- (void)controller:(id<CommonFetchedResultsController>)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;
@optional
- (void)controller:(id<CommonFetchedResultsController>)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type;
@optional
- (void)controllerWillChangeContent:(id<CommonFetchedResultsController>)controller;
@optional
- (void)controllerDidChangeContent:(id<CommonFetchedResultsController>)controller;
@end

@protocol CommonFetchedResultsController <NSObject>
@property (nonatomic, weak) id<CommonFetchedResultsControllerDelegate> delegate;
@property (nonatomic, readonly) NSArray *sections; // @[<NSFetchedResultsSectionInfo>]

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;
@end

@interface NSFetchedResultsController (CommonFetchedResultsController) <CommonFetchedResultsController>
@end


IB_DESIGNABLE
@interface FRCBaseAdapter : NSObject <CommonFetchedResultsControllerDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, weak) IBOutlet id forwardDelegate;
@property (nonatomic, copy) IBInspectable NSString *fetchRequestTemplateName;
@property (nonatomic, copy) IBInspectable NSString *sectionNameKeyPath;
@property (nonatomic, copy) IBInspectable NSString *cacheName;
@property (nonatomic, strong) id<CommonFetchedResultsController> listController;

- (void)resetListController;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;
@end



