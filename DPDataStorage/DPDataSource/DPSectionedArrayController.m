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
@property (nonatomic, readwrite, copy) NSInteger (^sectionHashCalculator)(id);
@property (nonatomic, strong) DPArrayControllerSection *innerStorage;
@property (nonatomic, strong) NSMutableArray<DPSectionChange *> *innerStorageChanges;
@property (nonatomic, strong) NSMutableArray<DPSectionChange *> *deleteSectionChanges;
@end


@implementation DPSectionedArrayController

- (instancetype)initWithDelegate:(id<DataSourceContainerControllerDelegate> _Nullable)delegate sectionHashCalculator:(NSInteger (^)(id))sectionHashCalculator sectionSortDescriptor:(NSSortDescriptor *)sectionSortDescriptor
{
    if ((self = [super initWithDelegate:delegate])) {
        self.sectionSortDescriptor = sectionSortDescriptor;
        self.sectionHashCalculator = sectionHashCalculator;
    }
    return self;
}

- (NSMutableArray *)innerStorageChanges {
    if (_innerStorageChanges == nil) _innerStorageChanges = [NSMutableArray new];
    return _innerStorageChanges;
}

- (NSMutableArray *)deleteSectionChanges {
    if (_deleteSectionChanges == nil) _deleteSectionChanges = [NSMutableArray new];
    return _deleteSectionChanges;
}

#pragma mark -

- (void)setSectionNameKeyPath:(NSString *)sectionNameKeyPath {
    _sectionNameKeyPath = [sectionNameKeyPath copy];
    _sectionNameSetter = nil;
    [self reloadSectionsName];
}

- (void)setSectionNameSetter:(NSString * _Nullable (^)(NSArray<id> * _Nullable))sectionNameSetter {
    _sectionNameSetter = sectionNameSetter;
    _sectionNameKeyPath = nil;
    [self reloadSectionsName];
}

- (DPArrayControllerSection *)innerStorage {
    if (_innerStorage == nil) _innerStorage = [DPArrayControllerSection new];
    return _innerStorage;
}

- (NSSortDescriptor *)inSectionSortDescriptor {
    return [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [@([self.innerStorage.objects indexOfObject:obj1]) compare:@([self.innerStorage.objects indexOfObject:obj2])];
    }];
}

- (void)_setSectionNameWithObjects:(NSArray *)objects atSection:(NSInteger)section {
    if (self.sectionNameKeyPath.length > 0) {
        NSString *name = [[objects.firstObject valueForKeyPath:self.sectionNameKeyPath] description];
        [self setSectionName:name atIndex:section];
    }
    else if (self.sectionNameSetter != nil) {
        NSString *name = self.sectionNameSetter(objects);
        [self setSectionName:name atIndex:section];
    }
}

- (void)_setObjects:(NSArray *)objects atSection:(NSInteger)section {
    NSParameterAssert(objects.count > 0);

    [super setObjects:objects atSection:section];
    [self _setSectionNameWithObjects:objects atSection:section];
    NSInteger hash = self.sectionHashCalculator(objects.firstObject);
    [(DPArrayControllerSection *)self.sections[section] setSectionHash:hash];
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
        NSArray *sortedObjects = [self.innerStorage.objects sortedArrayUsingDescriptors:@[self.sectionSortDescriptor, self.inSectionSortDescriptor]];
        NSMutableArray *sectionObjects = [NSMutableArray arrayWithObject:sortedObjects.firstObject];
        NSInteger sectionIndex = 0;

        for (NSInteger i = 1; i < sortedObjects.count; i++) {
            if ([self.sectionSortDescriptor compareObject:sortedObjects[i-1] toObject:sortedObjects[i]] != NSOrderedSame) {
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
    return [self.innerStorage objectAtIndex:index];
}

- (NSUInteger)indexOfObject:(id)object {
    return [self.innerStorage indexOfObject:object];
}

- (NSUInteger)numberOfObjects {
    return [self.innerStorage numberOfObjects];
}

#pragma mark -

- (void)insertObject:(id)object atIndex:(NSUInteger)index {
    [self.innerStorageChanges addObject:[DPSectionChange insertObject:object atIndex:index]];
    if (self.isUpdating == NO) {
        [self applyInnerStorageChanges];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    id object = [self objectAtIndex:index];
    [self.innerStorageChanges addObject:[DPSectionChange deleteObject:object atIndex:index]];
    if (self.isUpdating == NO) {
        [self applyInnerStorageChanges];
    }
}

- (void)reloadObjectAtIndex:(NSUInteger)index {
    id object = [self objectAtIndex:index];
    [self.innerStorageChanges addObject:[DPSectionChange updateObject:object atIndex:index]];
    if (self.isUpdating == NO) {
        [self applyInnerStorageChanges];
    }
}

- (void)moveObjectAtIndex:(NSUInteger)index toIndex:(NSUInteger)newIndex {
    id object = [self objectAtIndex:index];
    [self.innerStorageChanges addObject:[DPSectionChange moveObject:object atIndex:index newIndex:newIndex]];
    if (self.isUpdating == NO) {
        [self applyInnerStorageChanges];
    }
}

- (void)reloadObjectAtIndextPath:(NSIndexPath *)indexPath {
    id object = [super objectAtIndexPath:indexPath];
    NSUInteger index = [self indexOfObject:object];
    [self reloadObjectAtIndex:index];
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

#pragma mark -

- (void)endUpdating {
    [self applyInnerStorageChanges];
    [super endUpdating];

    for (NSInteger i = 0; i < [super numberOfSections]; i++) {
        NSInteger hash = self.sectionHashCalculator(self.sections[i].objects.firstObject);
        [(DPArrayControllerSection *)self.sections[i] setSectionHash:hash];
    }
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

#pragma mark -

- (DPSectionChange *)changeForObject:(id)object {
    for (DPSectionChange *c in self.innerStorageChanges) {
        if (c.anObject == object) return c;
    }
    return nil;
}

- (DPArrayControllerSection *)sectionWithHash:(NSInteger)hash {
    for (NSInteger i = 0; i < [super numberOfSections]; i++) {
        DPArrayControllerSection *section = (DPArrayControllerSection *)self.sections[i];
        if (section.sectionHash == hash) {
            return section;
        }
    }
    return nil;
}

- (id)firstAnchorObjectAtSection:(NSInteger)section {
    NSInteger sectionHash = [(DPArrayControllerSection *)self.sections[section] sectionHash];
    for (NSInteger i = 0; i < [self numberOfItemsInSection:section]; i++) {
        NSIndexPath *ip = [NSIndexPath indexPathForItem:i inSection:section];
        id object = [self objectAtIndexPath:ip];
        if (self.sectionHashCalculator(object) == sectionHash) {
            return object;
        }
    }
    return nil;
}

- (void)applyInnerStorageChanges {
    for (DPSectionChange *c in self.innerStorageChanges) {
        switch (c.type) {
            case NSFetchedResultsChangeInsert:
                [self.innerStorage insertObject:c.anObject atIndex:c.toIndex];
                break;

            case NSFetchedResultsChangeDelete:
                [self.innerStorage removeObjectAtIndex:c.index];
                break;

            case NSFetchedResultsChangeMove:
                [self.innerStorage moveObjectAtIndex:[self.innerStorage indexOfObject:c.anObject] toIndex:c.toIndex];
                break;

            case NSFetchedResultsChangeUpdate:
                break;
        }
    }
    [self.innerStorage removeDeletedObjectPlaceholders];

    // 'Simple' changes

    for (NSInteger i = self.innerStorageChanges.count - 1; i >= 0; i--) {
        DPSectionChange *c = self.innerStorageChanges[i];
        if (c.type == NSFetchedResultsChangeDelete) {
            [super deleteObjectAtIndextPath:[super indexPathForObject:c.anObject]];
            [self.innerStorageChanges removeObjectAtIndex:i];
        }
        else if (c.type == NSFetchedResultsChangeUpdate) {
            NSIndexPath *ip = [super indexPathForObject:c.anObject];
            NSInteger hash = self.sectionHashCalculator(c.anObject);
            if ([(DPArrayControllerSection *)self.sections[ip.section] sectionHash] == hash) {
                [super reloadObjectAtIndextPath:ip];
                [self.innerStorageChanges removeObjectAtIndex:i];
            }
        }
    }

    // Insert & Move changes
    NSMutableArray *allObjects = [[self.innerStorageChanges valueForKeyPath:@"anObject"] mutableCopy];
    for (NSInteger i = 0; i < [super numberOfSections]; i++) {
        id object = [self firstAnchorObjectAtSection:i];
        if (object != nil && [allObjects indexOfObject:object] == NSNotFound) {
            [allObjects addObject:object];
        }
    }

    [allObjects sortUsingDescriptors:@[self.sectionSortDescriptor, self.inSectionSortDescriptor]];

    if (allObjects.count > 0) {
        NSInteger sectionIndex = 0;
        NSInteger lastInsertedSectionIndex = -1;
        NSInteger itemShift = 0;
        NSInteger itemIndex = 0;
        NSInteger lastHash = self.sectionHashCalculator(allObjects.firstObject);

        for (id obj in allObjects) {
            NSInteger hash = self.sectionHashCalculator(obj);
            if (lastHash != hash) {
                itemShift = 0;
                itemIndex = 0;
                sectionIndex++;
            }
            lastHash = hash;

            DPSectionChange *c = [self changeForObject:obj];
            if (c != nil) {
                NSIndexPath *newIndexPath = nil;
                DPArrayControllerSection *section = [self sectionWithHash:hash];
                if (section != nil) {
                    for (; itemIndex < [section numberOfObjects]; itemIndex++) {
                        id firstObject = section.objects[itemIndex];
                        if ([self.innerStorage indexOfObject:firstObject] == NSNotFound || self.sectionHashCalculator(firstObject) != lastHash) {
                            itemShift--;
                            continue;
                        }
                        NSComparisonResult result = [self.inSectionSortDescriptor compareObject:firstObject toObject:obj];
                        if (result == NSOrderedDescending || result == NSOrderedSame) {
                            break;
                        }
                    }

                    newIndexPath = [NSIndexPath indexPathForRow:itemIndex + itemShift inSection:sectionIndex];
                    itemShift++;
                }
                else {
                    if (lastInsertedSectionIndex != sectionIndex) {
                        [super insertSectionAtIndex:sectionIndex];
                        lastInsertedSectionIndex = sectionIndex;
                    }
                    newIndexPath = [NSIndexPath indexPathForRow:itemIndex + itemShift inSection:sectionIndex];
                    itemShift++;
                }

                if (c.type == NSFetchedResultsChangeInsert) {
                    [super insertObject:obj atIndextPath:newIndexPath];
                }
                else {
                    NSIndexPath *from = [super indexPathForObject:c.anObject];
                    [super moveObjectAtIndextPath:from toIndexPath:newIndexPath];
                }
            }
        }
    }

    self.innerStorageChanges = nil;
}

@end
