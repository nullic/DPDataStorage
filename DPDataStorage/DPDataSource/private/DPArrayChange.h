//
//  DPArrayChange.h
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 3/7/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DPDataSourceContainer.h"

NS_ASSUME_NONNULL_BEGIN

@interface DPArrayChange : NSObject
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) NSUInteger newIndex;
@property (nonatomic, strong) id anObject;
@property (nonatomic, assign) NSFetchedResultsChangeType type;

+ (instancetype)insertObject:(id)anObject atIndex:(NSUInteger)index;
+ (instancetype)deleteObject:(id)anObject atIndex:(NSUInteger)index;
+ (instancetype)moveObject:(id)anObject atIndex:(NSUInteger)index newIndex:(NSUInteger)newIndex;
+ (instancetype)updateObject:(id)anObject atIndex:(NSUInteger)index;

- (void)sendChangeTo:(id<DataSourceContainerControllerDelegate>)delegate sectionIndex:(NSUInteger)section controller:(id<DataSourceContainerController>)controller;
- (void)sendSectionChangeTo:(id<DataSourceContainerControllerDelegate>)delegate controller:(id<DataSourceContainerController>)controller;

@end

NS_ASSUME_NONNULL_END
