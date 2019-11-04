//
//  DPSectionedFetchedResultsController.h
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 1/9/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPSectionedArrayController.h"
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DPSectionedFetchedResultsController : DPSectionedArrayController
- (instancetype)initWithDelegate:(id<DataSourceContainerControllerDelegate> _Nullable)delegate sectionHashCalculator:(NSInteger (^)(id ))sectionHashCalculator sectionSortDescriptor:(NSSortDescriptor *)sectionSortDescriptor NS_UNAVAILABLE;

- (instancetype)initWithDelegate:(id<DataSourceContainerControllerDelegate> _Nullable)delegate sectionHashCalculator:(NSInteger (^)(id ))sectionHashCalculator sectionSortDescriptor:(NSSortDescriptor *)sectionSortDescriptor frc:(NSFetchedResultsController *)frc NS_DESIGNATED_INITIALIZER;

- (void)startUpdating NS_UNAVAILABLE;
- (void)endUpdating NS_UNAVAILABLE;

- (void)setObjects:(NSArray * _Nullable)objects NS_UNAVAILABLE;

- (id)objectAtIndex:(NSUInteger)index NS_UNAVAILABLE;
- (NSUInteger)indexOfObject:(id)object NS_UNAVAILABLE;
- (NSUInteger)countOfObjects NS_UNAVAILABLE;

- (void)insertObject:(id)object atIndex:(NSUInteger)index NS_UNAVAILABLE;
- (void)removeObjectAtIndex:(NSUInteger)index NS_UNAVAILABLE;
- (void)reloadObjectAtIndex:(NSUInteger)index NS_UNAVAILABLE;
- (void)moveObjectAtIndex:(NSUInteger)index toIndex:(NSUInteger)newIndex NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
