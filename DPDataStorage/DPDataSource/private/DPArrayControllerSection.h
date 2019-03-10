//
//  DPArrayControllerSection.h
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 2/4/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DPArrayControllerSection : NSObject <NSFetchedResultsSectionInfo>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *indexTitle;
@property (nonatomic, readonly) NSUInteger numberOfObjects;
@property (nonatomic, readonly) NSArray *objects;

@property (nonatomic) NSUInteger index;

+ (instancetype)sectionWithIndex:(NSUInteger)index;

- (void)setObjects:(NSArray * _Nullable)objects;
- (void)insertObject:(id)object atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectWithObject:(id)object atIndex:(NSUInteger)index;
- (void)moveObjectAtIndex:(NSUInteger)index toIndex:(NSUInteger)newIndex;

- (void)addObjectsFromArray:(NSArray *)otherArray;
- (NSUInteger)indexOfObject:(id)object;
- (id)objectAtIndex:(NSUInteger)index;
@end

NS_ASSUME_NONNULL_END
