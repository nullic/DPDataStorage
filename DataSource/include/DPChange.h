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
@property (nonatomic, assign, getter=isApplied) BOOL applied;
@property (nonatomic, assign, getter=isNotified) BOOL notified;

@property (nonatomic, readonly) NSInteger applyOrder;

- (void)applyTo:(DPArrayController *)controller;
- (void)notifyDelegateOfController:(DPArrayController *)controller;
@end


@interface DPSectionChange : DPChange
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) NSUInteger toIndex;

+ (instancetype)insertObject:(id)anObject atIndex:(NSUInteger)index;
+ (instancetype)deleteObject:(id)anObject atIndex:(NSUInteger)index;
+ (instancetype)updateObject:(id)anObject atIndex:(NSUInteger)index;
+ (instancetype)moveObject:(id)anObject atIndex:(NSUInteger)index newIndex:(NSUInteger)newIndex;
@end


@interface DPItemChange : DPChange
@property (nonatomic, strong, nullable) NSIndexPath *path;
@property (nonatomic, strong, nullable) NSIndexPath *toPath;

- (NSInteger)affectSectionCountAtIndex:(NSInteger)index;

+ (instancetype)insertObject:(id)anObject atIndexPath:(NSIndexPath *)path;
+ (instancetype)deleteObject:(id)anObject atIndexPath:(NSIndexPath *)path;
+ (instancetype)moveObject:(id)anObject atIndexPath:(NSIndexPath *)path newIndex:(NSIndexPath *)newPath;
+ (instancetype)updateObject:(id)anObject atIndexPath:(NSIndexPath *)path newIndexPath:(nullable NSIndexPath *)newPath;
@end

NS_ASSUME_NONNULL_END
