//
//  DPSectionedArrayController.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 1/8/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPSectionedArrayController.h"
#import "DPArrayControllerSection.h"
#import "DPChange.h"

@interface DPSectionedArrayController ()
@property (nonatomic, readwrite, strong) NSSortDescriptor *sectionSortDescriptor;
@property (nonatomic, strong) DPArrayControllerSection *innerStorage;
@property (nonatomic, strong) NSMutableArray<DPSectionChange *> *insertedObjects;
@property (nonatomic, strong) NSMutableArray<DPSectionChange *> *deleteSectionChanges;
@end


@implementation DPSectionedArrayController

- (instancetype)initWithDelegate:(id<DataSourceContainerControllerDelegate> _Nullable)delegate sectionKeyPath:(NSString *)sectionKeyPath sectionSortDescriptor:(NSSortDescriptor *)sectionSortDescriptor
{
    if ((self = [super initWithDelegate:delegate])) {
        self.sectionKeyPath = sectionKeyPath;
        self.sectionSortDescriptor = sectionSortDescriptor;
    }
    return self;
}

- (NSMutableArray *)insertedObjects {
    if (_insertedObjects == nil) _insertedObjects = [NSMutableArray new];
    return _insertedObjects;
}

- (NSMutableArray *)deleteSectionChanges {
    if (_deleteSectionChanges == nil) _deleteSectionChanges = [NSMutableArray new];
    return _deleteSectionChanges;
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

- (DPArrayControllerSection *)innerStorage {
    if (_innerStorage == nil) _innerStorage = [DPArrayControllerSection new];
    return _innerStorage;
}

- (NSComparator)sectionComarator {
    return ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [@([self.innerStorage.objects indexOfObject:obj1]) compare:@([self.innerStorage.objects indexOfObject:obj2])];
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
    [super setObjects:objects atSection:section];
    [self _setSectionNameWithObjects:objects atSection:section];
}

#pragma mark -

- (void)reloadSectionsName {
    for (NSInteger i = 0; i < self.sections.count; i++) {
        NSArray *objects = self.sections[i].objects;
        [self _setSectionNameWithObjects:objects atSection:i];
    }
}

- (void)setObjects:(NSArray *)objects {
    [super removeAllObjects];
    [self.innerStorage setObjects:objects];

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
}

#pragma mark -

- (id)objectAtIndex:(NSUInteger)index {
    if (self.isUpdating) {
        return self.innerStorage.objects[index];
    } else {
        return [self.innerStorage objectAtIndex:index];
    }
}

- (NSUInteger)indexOfObject:(id)object {
    return [self.innerStorage indexOfObject:object];
}

- (NSUInteger)numberOfObjects {
    return [self.innerStorage numberOfObjects];
}

- (NSIndexPath *)newIndexPathForObject:(id)object newSection:(BOOL *)newSection {
    NSInteger section = 0;

    for (; section < [self numberOfSections]; section++) {
        id firstObject = nil;

        for (NSInteger i = 0; i < [self numberOfItemsInSection:section]; i++) {
            NSIndexPath *ip = [NSIndexPath indexPathForItem:i inSection:section];
            id otherObject = [self objectAtIndexPath:ip];
            if (otherObject == object) continue;
            if ([self.innerStorage indexOfObject:otherObject] != NSNotFound) {
                firstObject = otherObject;
                break;
            }
        }

        if (firstObject == nil) continue;

        NSComparisonResult result = [self.sectionSortDescriptor compareObject:firstObject toObject:object];
        if (result == NSOrderedSame) {
            NSUInteger item = 0;
            for (; item < [self numberOfItemsInSection:section]; item++) {
                NSIndexPath *ip = [NSIndexPath indexPathForItem:item inSection:section];
                id firstObject = [self objectAtIndexPath:ip];

                [self.innerStorage removeDeletedObjectPlaceholders];
                NSComparisonResult result = self.sectionComarator(firstObject, object);
                if (result != NSOrderedAscending) {
                    break;
                }
            }

            *newSection = NO;
            return [NSIndexPath indexPathForItem:item inSection:section];
        }
        else if (result == NSOrderedDescending) {
            break;
        }
    }

    NSInteger prevSection = (section - 1);
    if (prevSection >= 0 && [self numberOfItemsInSection:prevSection] == 0) {
        *newSection = NO;
        return [NSIndexPath indexPathForItem:0 inSection:prevSection];
    } else {
        *newSection = YES;
        return [NSIndexPath indexPathForItem:0 inSection:section];
    }
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index {
    if (self.isUpdating) {
        [self.insertedObjects addObject:[DPSectionChange insertObject:object atIndex:index]];
    } else {
        [self.innerStorage insertObject:object atIndex:index];

        BOOL newSection = NO;
        NSIndexPath *indexPath = [self newIndexPathForObject:object newSection:&newSection];
        if (newSection == YES) {
            [super insertSectionAtIndex:indexPath.section];
        }
        [super insertObject:object atIndextPath:indexPath];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    id object = [self objectAtIndex:index];
    [self.innerStorage removeObjectAtIndex:index];

    NSIndexPath *indexPath = [super indexPathForObject:object];
    [super deleteObjectAtIndextPath:indexPath];
}

- (void)reloadObjectAtIndex:(NSUInteger)index {
    id object = [self objectAtIndex:index];
    [self removeObjectAtIndex:index];
    [self insertObject:object atIndex:index];
}

- (void)moveObjectAtIndex:(NSUInteger)index toIndex:(NSUInteger)newIndex {
    id object = [self objectAtIndex:index];
    [self removeObjectAtIndex:index];
    [self insertObject:object atIndex:newIndex];
}

- (void)reloadObjectAtIndextPath:(NSIndexPath *)indexPath {
    id object = [super objectAtIndexPath:indexPath];
    NSUInteger index = [self indexOfObject:object];
    [self reloadObjectAtIndex:index];
}

#pragma mark -

- (void)endUpdating {
    [self applyInsertion];
    [super endUpdating];
}

- (void)applyChanges {
    [super applyChanges];
    [self removeEmptySections];
}

- (void)notifyDelegate {
    [super notifyDelegate];
    for (DPSectionChange *change in self.deleteSectionChanges) {
        [change notifyDelegateOfController:self];
    }
    self.deleteSectionChanges = nil;
}

- (void)applyInsertion {
    if (self.insertedObjects.count == 0) return;

    [self.insertedObjects sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]];

    NSInteger sectionShift = 0;
    NSInteger itemShift = 0;
    id prevObject = nil;
    for (DPSectionChange *c in self.insertedObjects) {
        [self.innerStorage insertObject:c.anObject atIndex:c.index];

        BOOL newSection = NO;
        NSIndexPath *indexPath = [self newIndexPathForObject:c.anObject newSection:&newSection];
        indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section + sectionShift];
        if (newSection == YES) {
            NSComparisonResult result = prevObject != nil ? [self.sectionSortDescriptor compareObject:prevObject toObject:c.anObject] : NSOrderedAscending;
            if (result == NSOrderedSame) {
                itemShift++;
                indexPath = [NSIndexPath indexPathForItem:indexPath.item + itemShift inSection:indexPath.section - 1];
            } else {
                sectionShift++;
                itemShift = 0;
                [super insertSectionAtIndex:indexPath.section];
            }
        } else {
            NSComparisonResult result = prevObject != nil ? [self.sectionSortDescriptor compareObject:prevObject toObject:c.anObject] : NSOrderedAscending;
            if (result == NSOrderedSame) {
                itemShift++;
                indexPath = [NSIndexPath indexPathForItem:indexPath.item + itemShift inSection:indexPath.section];
            } else {
                itemShift = 0;
            }
        }

        [super insertObject:c.anObject atIndextPath:indexPath];
        prevObject = c.anObject;
    }

    self.insertedObjects = nil;
}

- (void)removeEmptySections {
    NSInteger count = [self numberOfSections];
    for (NSInteger i = 0; i < count; i++) {
        id section = self.sections[i];
        if ([section numberOfObjects] == 0) {
            DPSectionChange *change = [DPSectionChange deleteObject:section atIndex:i];
            [change applyTo:self];
            [self.deleteSectionChanges addObject:change];
        }
    }
}

@end
