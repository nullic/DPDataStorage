//
//  DPArrayControllerSection.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 2/4/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPArrayControllerSection.h"
#import "DPPendingObject.h"


@interface DPArrayControllerSection ()
@property (nonatomic, readwrite, strong) NSMutableArray *mutableObjects;
@property (nonatomic, readwrite, strong) NSMutableArray *deleteChanges;
@property (nonatomic, readwrite, strong) NSMutableArray *insertChanges;

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

- (NSMutableArray *)insertChanges {
    if (_insertChanges == nil) _insertChanges = [NSMutableArray new];
    return _insertChanges;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ {numberOfObjects: %lu}", [super description], (unsigned long)self.numberOfObjects];
}

- (NSUInteger)numberOfObjects {
    return self.objects.count - self.deleteChanges.count + self.insertChanges.count;
}

- (NSString *)name {
    return _name ?: @"";
}

#pragma mark - array mutating

- (void)setObjects:(NSArray *)objects {
    self.mutableObjects = [objects mutableCopy];
    self.deleteChanges = nil;
    self.insertChanges = nil;
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index {
    [self.insertChanges addObject:[DPPendingObject objectWithObject:object index:index]];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    id object = self.mutableObjects[index];
    [self.deleteChanges addObject:[DPPendingObject objectWithObject:object index:index]];
}

- (void)replaceObjectWithObject:(id)object atIndex:(NSUInteger)index {
    [self.mutableObjects replaceObjectAtIndex:index withObject:object];
}

- (void)moveObjectAtIndex:(NSUInteger)index toIndex:(NSUInteger)newIndex {
    id object = self.mutableObjects[index];
    [self.deleteChanges addObject:[DPPendingObject objectWithObject:object index:index]];
    [self.insertChanges addObject:[DPPendingObject objectWithObject:object index:newIndex]];
}

- (void)addObjectsFromArray:(NSArray *)otherArray {
    [self applyPendingChanges];
    
    NSInteger initialIndex = [self numberOfObjects];
    for (NSInteger i = 0; i < otherArray.count; i++) {
        [self insertObject:otherArray[i] atIndex:i + initialIndex];
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

- (void)applyPendingChanges {
    [self applyDeletedChanges];
    [self applyInsertChanges];
}

- (void)applyInsertChanges {
    if (self.insertChanges.count > 0) {
        [self.insertChanges sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:true]]];
        for (DPPendingObject *object in self.insertChanges) {
            [self.mutableObjects insertObject:object.anObject atIndex:object.index];
        }
        self.insertChanges = nil;
    }
}

- (void)applyDeletedChanges {
    if (self.deleteChanges.count > 0) {
        [self.deleteChanges sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:true]]];
        for (DPPendingObject *object in [self.deleteChanges reverseObjectEnumerator]) {
            [self.mutableObjects removeObjectAtIndex:object.index];
        }
        self.deleteChanges = nil;
    }
}

@end
