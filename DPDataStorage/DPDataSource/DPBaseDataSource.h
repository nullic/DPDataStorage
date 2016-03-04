//
//  DPBaseDataSource.h
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 27/04/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

@import UIKit;

#import "DPDataSourceCell.h"
#import "DPDataSourceContainer.h"

@interface NSFetchedResultsController (DataSourceContainerController) <DataSourceContainerController>
@property (nonatomic, readonly) BOOL hasData;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
@end

IB_DESIGNABLE
@interface DPBaseDataSource : NSObject <DataSourceContainerControllerDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, weak) IBOutlet id forwardDelegate;
@property (nonatomic, strong, nullable) IBOutlet id<DataSourceContainerController> listController;
@property (nonatomic, readonly) BOOL hasData;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (id _Null_unspecified)objectAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (NSIndexPath * _Nullable)indexPathForObject:(id _Nonnull)object;
@end



