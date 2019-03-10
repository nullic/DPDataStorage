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

@class DPArrayController;

NS_ASSUME_NONNULL_BEGIN

@interface DPChange : NSObject
@property (nonatomic, strong) id anObject;
@property (nonatomic, assign) NSFetchedResultsChangeType type;

- (void)applyTo:(DPArrayController *)controller;

- (NSComparisonResult)compare:(DPChange *)other;
@end


@interface DPSectionChange : DPChange
@property (nonatomic, assign) NSUInteger index;

+ (instancetype)insertObject:(id)anObject atIndex:(NSUInteger)index;
+ (instancetype)deleteObject:(id)anObject atIndex:(NSUInteger)index;
+ (instancetype)updateObject:(id)anObject atIndex:(NSUInteger)index;


@end


@interface DPItemChange : DPChange
@property (nonatomic, assign, nullable) NSIndexPath *path;
@property (nonatomic, assign, nullable) NSIndexPath *toPath;

+ (instancetype)insertObject:(id)anObject atIndexPath:(NSIndexPath *)path;
+ (instancetype)deleteObject:(id)anObject atIndexPath:(NSIndexPath *)path;
+ (instancetype)moveObject:(id)anObject atIndexPath:(NSIndexPath *)path newIndex:(NSIndexPath *)newPath;
+ (instancetype)updateObject:(id)anObject atIndexPath:(NSIndexPath *)path newIndexPath:(nullable NSIndexPath *)newPath;
@end

NS_ASSUME_NONNULL_END
