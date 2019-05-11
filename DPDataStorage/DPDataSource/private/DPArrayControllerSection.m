//
//  DPArrayControllerSection.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 2/4/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPArrayControllerSection.h"
#import "DPPlaceholderObject.h"


@interface DPArrayControllerSection ()
@property (nonatomic, readwrite, strong) NSMutableArray *mutableObjects;
@property (nonatomic, readwrite, strong) NSMutableArray *deleteChanges;

@property (nonatomic) NSFetchedResultsChangeType lastChangeType;
@end


@implementation DPArrayControllerSection
@synthesize name = _name;

- (NSArray *)objects {
    return self.mutableObjects;
}

- (NSMutableArray *)mutableObjects {
    if (_mutableObjects == nil) _mutableObjects = [NSMutableArray new];
    return _mutableObjects;
}

- (NSMutableArray *)deleteChanges {
    if (_deleteChanges == nil) _deleteChanges = [NSMutableArray new];
    return _deleteChanges;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ {numberOfObjects: %lu}", [super description], (unsigned long)self.numberOfObjects];
}

- (NSUInteger)numberOfObjects {
    return self.objects.count - self.deleteChanges.count;
}

- (NSString *)name {
    return _name ?: @"";
}

- (void)setLastChangeType:(NSFetchedResultsChangeType)lastChangeType {
    if (_lastChangeType != lastChangeType) {
        _lastChangeType = lastChangeType;
        [self removeDeletedObjectPlaceholders];
    }
}

#pragma mark - array mutating

- (void)setObjects:(NSArray *)objects {
    self.mutableObjects = [objects mutableCopy];
    self.deleteChanges = nil;
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index {
    self.lastChangeType = NSFetchedResultsChangeInsert;
    [self _insertObject: object atIndex:index];
}

- (void)_insertObject:(id)object atIndex:(NSUInteger)index {
    if (index > [self numberOfObjects]) {
        while (index >= [self numberOfObjects]) {
            [self.mutableObjects insertObject:[DPInsertedPlaceholderObject new] atIndex:[self numberOfObjects]];
        }
    }

    if (index < [self numberOfObjects] && [[self.mutableObjects objectAtIndex:index] isKindOfClass:[DPInsertedPlaceholderObject class]]) {
        [self.mutableObjects removeObjectAtIndex:index];
    }

    [self.mutableObjects insertObject:object atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    self.lastChangeType = NSFetchedResultsChangeDelete;

    id object = self.mutableObjects[index];
    [self.mutableObjects replaceObjectAtIndex:index withObject:[DPDeletedPlaceholderObject placeholderWithObject: object]];
    [self.deleteChanges addObject:@(index)];
}

- (void)replaceObjectWithObject:(id)object atIndex:(NSUInteger)index {
    self.lastChangeType = NSFetchedResultsChangeUpdate;
    [self.mutableObjects replaceObjectAtIndex:index withObject:object];
}

- (void)moveObjectAtIndex:(NSUInteger)index toIndex:(NSUInteger)newIndex {
    self.lastChangeType = NSFetchedResultsChangeMove;

    id object = self.mutableObjects[index];
    [self.mutableObjects removeObjectAtIndex:index];
    [self _insertObject: object atIndex:newIndex];
}

- (void)addObjectsFromArray:(NSArray *)otherArray {
    self.lastChangeType = NSFetchedResultsChangeInsert;

    for (id object in otherArray) {
        [self insertObject:object atIndex:[self numberOfObjects]];
    }
}

- (NSUInteger)indexOfManagedObject:(NSManagedObject *)object {
    NSUInteger result = NSNotFound;
    if (object) {
        id left = [object objectID];

        for (NSInteger index = 0; index < [self numberOfObjects]; index++) {
            id right = [self objectAtIndex:index];
            right = [right isKindOfClass:[NSManagedObject class]] ? [right objectID] : right;

            if ([left isEqual:right]) {
                result = index;
                break;
            }
        }
    }
    return result;
}

- (NSUInteger)indexOfObject:(id)object {
    return [self.objects indexOfObject:object];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [self.mutableObjects objectAtIndex:index];
}

- (void)removeDeletedObjectPlaceholders {
    if (self.deleteChanges.count > 0) {
        [self.deleteChanges sortUsingSelector:@selector(compare:)];
        for (NSNumber *index in [self.deleteChanges reverseObjectEnumerator]) {
            [self.mutableObjects removeObjectAtIndex:index.integerValue];
        }
        self.deleteChanges = nil;
    }
}

@end
