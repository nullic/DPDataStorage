//
//  DPFetchedResultsBasedController.h
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 1/21/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPFilteredArrayController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DPContainerControllerBasedController : DPArrayController <DataSourceContainerControllerDelegate>
- (instancetype)initWithDelegate:(id<DataSourceContainerControllerDelegate> _Nullable)delegate NS_UNAVAILABLE;
- (instancetype)initWithDelegate:(id<DataSourceContainerControllerDelegate> _Nullable)delegate otherController:(id<DataSourceContainerController>)controller NS_DESIGNATED_INITIALIZER;

- (void)removeAllObjects NS_UNAVAILABLE;
- (void)insertObject:(id)object atIndextPath:(NSIndexPath *)indexPath NS_UNAVAILABLE;
- (void)deleteObjectAtIndextPath:(NSIndexPath *)indexPath NS_UNAVAILABLE;
- (void)reloadObjectAtIndextPath:(NSIndexPath *)indexPath NS_UNAVAILABLE;
- (void)moveObjectAtIndextPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath NS_UNAVAILABLE;

- (void)insertSectionAtIndex:(NSUInteger)index NS_UNAVAILABLE;
- (void)removeSectionAtIndex:(NSUInteger)index NS_UNAVAILABLE;
- (void)reloadSectionAtIndex:(NSUInteger)index NS_UNAVAILABLE;

- (void)addObjects:(NSArray *)objects atSection:(NSInteger)section NS_UNAVAILABLE;
- (void)setObjects:(NSArray *)objects atSection:(NSInteger)section NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
