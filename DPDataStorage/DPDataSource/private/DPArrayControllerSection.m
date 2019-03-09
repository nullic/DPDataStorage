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
@property (nonatomic, readwrite, strong) NSMutableArray<DPArrayChange *> *insertChanges;
@property (nonatomic, readwrite, strong) NSMutableArray<DPArrayChange *> *deleteChanges;
@property (nonatomic, readwrite, strong) NSMutableArray<DPArrayChange *> *changes;
@end


@implementation DPArrayControllerSection
@synthesize name = _name;

+ (instancetype)sectionWithIndex:(NSUInteger)index {
    DPArrayControllerSection *section = [self new];
    section.index = index;
    return section;
}

- (NSArray *)objects {
    return self.mutableObjects;
}

- (NSMutableArray *)mutableObjects {
    if (_mutableObjects == nil) _mutableObjects = [NSMutableArray new];
    return _mutableObjects;
}

- (NSMutableArray *)changes {
    if (_changes == nil) _changes = [NSMutableArray new];
    return _changes;
}

- (NSMutableArray *)insertChanges {
    if (_insertChanges == nil) _insertChanges = [NSMutableArray new];
    return _insertChanges;
}

- (NSMutableArray *)deleteChanges {
    if (_deleteChanges == nil) _deleteChanges = [NSMutableArray new];
    return _deleteChanges;
}

- (NSString *)description {return [NSString stringWithFormat:@"%@ {numberOfObjects: %lu}", [super description], (unsigned long)self.numberOfObjects];}
- (NSUInteger)numberOfObjects {return self.objects.count;};
- (NSString *)name {return _name ?: @"";}

#pragma mark - array mutating

- (void)setObjects:(NSArray *)objects {
    self.mutableObjects = [objects mutableCopy];
//    for (NSUInteger i = 0; i < [self numberOfObjects]; i++) {
//        [self removeObjectAtIndex:i];
//    }
//
//    for (id object in objects) {
//        [self insertObject:object atIndex:[self numberOfObjects]];
//    }
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index {
//    [self removeDeletedObjectPlaceholders];
    
    if (index > [self numberOfObjects]) {
        while (index >= [self numberOfObjects]) {
            [self.mutableObjects insertObject:[DPPlaceholderObject new] atIndex:[self numberOfObjects]];
        }
    }

    if (index < [self numberOfObjects] && [[self.mutableObjects objectAtIndex:index] isKindOfClass:[DPPlaceholderObject class]]) {
        [self.mutableObjects removeObjectAtIndex:index];
    }

    [self.mutableObjects insertObject:[DPInsertedPlaceholderObject placeholderWithObject: object] atIndex:index];
    DPArrayChange *change = [DPArrayChange insertObject:object atIndex:index];
    [self.changes addObject:change];
    [self.insertChanges addObject:change];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    id object = self.mutableObjects[index];
    [self.mutableObjects replaceObjectAtIndex:index withObject:[DPDeletedPlaceholderObject placeholderWithObject: object]];
    DPArrayChange *change = [DPArrayChange deleteObject:object atIndex:index];
    [self.changes addObject:change];
    [self.deleteChanges addObject:change];
}

- (void)replaceObjectWithObject:(id)object atIndex:(NSUInteger)index {
    [self.mutableObjects replaceObjectAtIndex:index withObject:object];
    [self.changes addObject:[DPArrayChange updateObject:object atIndex:index]];
}

- (void)moveObjectAtIndex:(NSUInteger)index toIndex:(NSUInteger)newIndex {
    id object = self.mutableObjects[index];
    [self.mutableObjects removeObjectAtIndex:index];
    [self.mutableObjects insertObject:object atIndex:newIndex];
    [self.changes addObject:[DPArrayChange moveObject:object atIndex:index newIndex:newIndex]];
}

- (void)addObjectsFromArray:(NSArray *)otherArray {
    for (id object in otherArray) {
        [self insertObject:object atIndex:[self numberOfObjects]];
    }
}

- (NSUInteger)indexOfObject:(id)object {
    NSUInteger result = NSNotFound;
    if (object) {
        id left = [object isKindOfClass:[NSManagedObject class]] ? [object objectID] : object;

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

- (id)objectAtIndex:(NSUInteger)index {
    id object = [self.mutableObjects objectAtIndex:index];
    return [object isKindOfClass:[DPBasePlaceholderObject class]] ? ([object anObject] ?: object)  : object;
}

- (void)removePlaceholderObjects {
    NSInteger count = [self numberOfObjects];
    for (NSUInteger i = count; i > 0; i--) {
        NSUInteger index = i - 1;

        if ([self.mutableObjects[index] isKindOfClass:[DPDeletedPlaceholderObject class]]) {
            [self.mutableObjects removeObjectAtIndex:index];
        }
        else if ([self.mutableObjects[index] isKindOfClass:[DPInsertedPlaceholderObject class]]) {
            DPInsertedPlaceholderObject *placeholder = self.mutableObjects[index];
            [self.mutableObjects replaceObjectAtIndex:index withObject:[placeholder anObject]];
        }
    }
}

//- (void)removeDeletedObjectPlaceholders {
//    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:false];
//    [self.deleteChanges sortUsingDescriptors:@[sort]];
//    for (DPArrayChange *c in self.deleteChanges) {
//        [self.mutableObjects removeObjectAtIndex:c.index];
//    }
//    self.deleteChanges = nil;
//}

- (void)clearUpdateChanges {
    self.changes = nil;
    self.insertChanges = nil;
    self.deleteChanges = nil;
}

- (NSArray<DPArrayChange *> *)updateChanges {
    return [self changes];
}

@end
