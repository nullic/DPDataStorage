//
//  DPBaseDataSource.h
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 27/04/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "DPDataSourceContainer.h"

IB_DESIGNABLE
@interface DPBaseDataSource : NSObject <DataSourceContainerControllerDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, weak) IBOutlet id forwardDelegate;
@property (nonatomic, copy) IBInspectable NSString *fetchRequestTemplateName;
@property (nonatomic, copy) IBInspectable NSString *sectionNameKeyPath;
@property (nonatomic, copy) IBInspectable NSString *cacheName;
@property (nonatomic, strong) id<DataSourceContainerController> listController;

- (void)resetListController;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;
@end



