//
//  MOArrayController.h
//  Commentator
//
//  Created by Dmitriy Petrusevich on 23/07/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <DPDataStorage/FRCBaseAdapter.h>

@interface MOArrayController : NSObject <CommonFetchedResultsController>
@property (nonatomic, weak) id<CommonFetchedResultsControllerDelegate> delegate;

- (instancetype)initWithDelegate:(id<CommonFetchedResultsControllerDelegate>)delegate;

- (void)removeAllObjects;

- (void)insertObject:(NSManagedObject *)object atIndextPath:(NSIndexPath *)indexPath;
- (void)deleteObjectAtIndextPath:(NSIndexPath *)indexPath;
- (void)addObjects:(NSArray *)objects atSection:(NSInteger)section;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;
@end
