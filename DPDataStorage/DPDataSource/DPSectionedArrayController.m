//
//  DPSectionedArrayController.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 1/8/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPSectionedArrayController.h"
#import "DPArrayControllerSection.h"


@interface DPSectionedArrayController ()
@property (nonatomic, readwrite, strong) NSSortDescriptor *sectionSortDescriptor;
@property (nonatomic, strong) DPArrayControllerSection *innerStorage;
@end


@implementation DPSectionedArrayController

- (instancetype)initWithDelegate:(id<DataSourceContainerControllerDelegate> _Nullable)delegate sectionKeyPath:(NSString *)sectionKeyPath sectionSortDescriptor:(NSSortDescriptor *)sectionSortDescriptor
{
    if ((self = [super initWithDelegate:delegate])) {
        self.removeEmptySectionsAutomaticaly = YES;
        self.sectionKeyPath = sectionKeyPath;
        self.sectionSortDescriptor = sectionSortDescriptor;
    }
    return self;
}

#pragma mark -

- (void)setSectionKeyPath:(NSString *)sectionKeyPath {
    _sectionKeyPath = [sectionKeyPath copy];
    _sectionNameSetter = nil;
    [self reloadSectionsName];
}

- (void)setSectionNameSetter:(NSString * _Nullable (^)(NSArray<id> * _Nullable))sectionNameSetter {
    _sectionNameSetter = sectionNameSetter;
    _sectionKeyPath = nil;
    [self reloadSectionsName];
}

- (void)setRemoveEmptySectionsAutomaticaly:(BOOL)removeEmptySectionsAutomaticaly {
    [super setRemoveEmptySectionsAutomaticaly:YES];
}

- (DPArrayControllerSection *)innerStorage {
    if (_innerStorage == nil) _innerStorage = [DPArrayControllerSection new];
    return _innerStorage;
}

- (NSComparator)sectionComarator {
    return ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [@([self.innerStorage indexOfObject:obj1]) compare:@([self.innerStorage indexOfObject:obj2])];
    };
}

- (void)_setSectionNameWithObjects:(NSArray *)objects atSection:(NSInteger)section {
    if (self.sectionKeyPath.length > 0) {
        NSString *name = [[objects.firstObject valueForKeyPath:self.sectionKeyPath] description];
        [self setSectionName:name atIndex:section];
    }
    else if (self.sectionNameSetter != nil) {
        NSString *name = self.sectionNameSetter(objects);
        [self setSectionName:name atIndex:section];
    }
}

- (void)_setObjects:(NSArray *)objects atSection:(NSInteger)section {
    [self _setSectionNameWithObjects:objects atSection:section];
    [super setObjects:objects atSection:section];
}

#pragma mark -

- (void)reloadSectionsName {
    for (NSInteger i = 0; i < self.sections.count; i++) {
        NSArray *objects = self.sections[i].objects;
        [self _setSectionNameWithObjects:objects atSection:i];
    }
}

- (void)setObjects:(NSArray *)objects {
    [super startUpdating];

    [super removeAllObjects];
    self.innerStorage = [objects mutableCopy];

    if (objects.count > 0) {
        NSArray *sortedObjects = [self.innerStorage.objects sortedArrayUsingDescriptors:@[self.sectionSortDescriptor]];
        NSMutableArray *sectionObjects = [NSMutableArray arrayWithObject:sortedObjects.firstObject];
        NSInteger sectionIndex = 0;

        for (NSInteger i = 1; i < sortedObjects.count; i++) {
            if ([self.sectionSortDescriptor compareObject:sortedObjects[i-1] toObject:sortedObjects[i]] != NSOrderedSame) {
                [sectionObjects sortUsingComparator:self.sectionComarator];
                [self _setObjects:sectionObjects atSection:sectionIndex];
                sectionObjects = [NSMutableArray array];
                sectionIndex++;
            }

            [sectionObjects addObject:sortedObjects[i]];
        }

        [self _setObjects:sectionObjects atSection:sectionIndex];
    }

    [super endUpdating];
}

#pragma mark -

- (id)objectAtIndex:(NSUInteger)index {
    return [self.innerStorage objectAtIndex:index];
}

- (NSUInteger)indexOfObject:(id)object {
    return [self.innerStorage indexOfObject:object];
}

- (NSUInteger)countOfObjects {
    return [self.innerStorage.objects count];
}

- (NSIndexPath *)newIndexPathForObject:(id)object newSection:(BOOL *)newSection {
    NSUInteger section = 0;

    for (; section < [self numberOfSections]; section++) {
        NSIndexPath *ip = [NSIndexPath indexPathForItem:0 inSection:section];
        id firstObject = [self objectAtIndexPath:ip];
        if (firstObject == nil) continue;

        NSComparisonResult result = [self.sectionSortDescriptor compareObject:firstObject toObject:object];
        if (result == NSOrderedSame) {
            NSMutableArray *objects = [self.sections[section].objects mutableCopy];
            [objects addObject:object];
            [objects sortUsingComparator:self.sectionComarator];
            NSUInteger item = [objects indexOfObject:object];

            *newSection = NO;
            return [NSIndexPath indexPathForItem:item inSection:section];
        }
        else if (result == NSOrderedDescending) {
            break;
        }
    }

    *newSection = YES;
    return [NSIndexPath indexPathForItem:0 inSection:section];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index {
    [self startUpdating];
    [self.innerStorage insertObject:object atIndex:index];

    BOOL newSection = NO;
    NSIndexPath *indexPath = [self newIndexPathForObject:object newSection:&newSection];
    if (newSection == YES) {
        [super insertSectionAtIndex:indexPath.section];
    }
    [super insertObject:object atIndextPath:indexPath];

    [self endUpdating];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [self startUpdating];

    id object = [self.innerStorage objectAtIndex:index];
    [self.innerStorage removeObjectAtIndex:index];

    NSIndexPath *indexPath = [super indexPathForObject:object];
    [super deleteObjectAtIndextPath:indexPath];

    [self endUpdating];
}

- (void)reloadObjectAtIndex:(NSUInteger)index {
    [self startUpdating];
    id object = [self.innerStorage objectAtIndex:index];

    BOOL newSection = NO;
    NSIndexPath *newIndexPath = [self newIndexPathForObject:object newSection:&newSection];
    NSIndexPath *currentIndexPath = [self indexPathForObject:object];

    if (newSection == YES) {
        [self removeObjectAtIndex:index];
        [self insertObject:object atIndex:index];
    }
    else if ([currentIndexPath isEqual:newIndexPath] == NO) {
        [super moveObjectAtIndextPath:currentIndexPath toIndexPath:newIndexPath];
    } else {
        [super reloadObjectAtIndextPath:currentIndexPath];
    }

    [self endUpdating];
}

- (void)moveObjectAtIndex:(NSUInteger)index toIndex:(NSUInteger)newIndex {
    [self startUpdating];
    id object = [self.innerStorage objectAtIndex:index];

    [self removeObjectAtIndex:index];
    [self insertObject:object atIndex:newIndex];
    [self endUpdating];
}

- (void)reloadObjectAtIndextPath:(NSIndexPath *)indexPath {
    id object = [super objectAtIndexPath:indexPath];
    NSUInteger index = [self indexOfObject:object];
    [self reloadObjectAtIndex:index];
}

@end
