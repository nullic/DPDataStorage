//
//  DPArrayController+Private.h
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 3/22/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPArrayController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DPArrayController()
- (void)setNextChangeType:(NSFetchedResultsChangeType)nextChangeType;

- (void)removeAllObjectsImmediately:(BOOL)immediately;
- (void)insertObject:(id)object atIndextPath:(NSIndexPath *)indexPath immediately:(BOOL)immediately;
- (void)deleteObjectAtIndextPath:(NSIndexPath *)indexPath immediately:(BOOL)immediately;
- (void)reloadObjectAtIndextPath:(NSIndexPath *)indexPath immediately:(BOOL)immediately;
- (void)moveObjectAtIndextPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath immediately:(BOOL)immediately;

- (void)insertSectionAtIndex:(NSUInteger)index immediately:(BOOL)immediately;
- (void)insertSectionObject:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)index immediately:(BOOL)immediately;
- (void)removeSectionAtIndex:(NSUInteger)index immediately:(BOOL)immediately;
- (void)reloadSectionAtIndex:(NSUInteger)index immediately:(BOOL)immediately;

- (void)addObjects:(NSArray *)objects atSection:(NSInteger)section immediately:(BOOL)immediately;
- (void)setObjects:(NSArray *)objects atSection:(NSInteger)section immediately:(BOOL)immediately;
@end

NS_ASSUME_NONNULL_END
