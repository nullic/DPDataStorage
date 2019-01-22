//
//  DPBaseDataSource.h
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 27/04/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DPDataSourceCell.h"
#import "DPDataSourceContainer.h"

@interface NSFetchedResultsController (DataSourceContainerController) <DataSourceContainerController>
@property (nonatomic, readonly) BOOL hasData;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
@end

IB_DESIGNABLE
@interface DPBaseDataSource : NSObject <DataSourceContainerControllerDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, weak, nullable) IBOutlet id forwardDelegate;
@property (nonatomic, strong, nullable) IBOutlet id<DataSourceContainerController> listController;
@property (nonatomic, readonly) BOOL hasData;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (id _Nullable)objectAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (NSArray<id> * _Nonnull)objectsAtIndexPaths:(NSArray<NSIndexPath *> * _Nonnull)indexPaths;
- (NSIndexPath * _Nullable)indexPathForObject:(id _Nonnull)object;
@end



