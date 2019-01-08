//
//  DPSectionedArrayController.h
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 1/8/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import <DPDataStorage/DPDataStorage.h>

NS_ASSUME_NONNULL_BEGIN

@interface DPSectionedArrayController : DPArrayController
@property (nonatomic, strong) NSSortDescriptor *sectionSortDescriptor;
@property (nonatomic, copy, nullable) NSString *sectionKeyPath;
 
- (instancetype)initWithDelegate:(id<DataSourceContainerControllerDelegate> _Nullable)delegate sectionKeyPath:(NSString * _Nullable)sectionKeyPath sectionSortDescriptor:(NSSortDescriptor *)sectionSortDescriptor NS_DESIGNATED_INITIALIZER;

- (void)setObjects:(NSArray * _Nullable)objects;

- (void)insertObject:(id)object atIndextPath:(NSIndexPath *)indexPath NS_UNAVAILABLE;
- (void)deleteObjectAtIndextPath:(NSIndexPath *)indexPath NS_UNAVAILABLE;
- (void)reloadObjectAtIndextPath:(NSIndexPath *)indexPath NS_UNAVAILABLE;
- (void)moveObjectAtIndextPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath NS_UNAVAILABLE;

- (void)insertSectionAtIndex:(NSUInteger)index NS_UNAVAILABLE;
- (void)removeSectionAtIndex:(NSUInteger)index NS_UNAVAILABLE;
- (void)reloadSectionAtIndex:(NSUInteger)index NS_UNAVAILABLE;
- (void)removeEmptySections NS_UNAVAILABLE;

- (void)addObjects:(NSArray *)objects atSection:(NSInteger)section NS_UNAVAILABLE;
- (void)setObjects:(NSArray *)objects atSection:(NSInteger)section NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
