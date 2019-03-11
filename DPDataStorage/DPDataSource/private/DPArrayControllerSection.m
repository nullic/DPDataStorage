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
@end


@implementation DPArrayControllerSection
@synthesize name = _name;

+ (instancetype)sectionWithIndex:(NSUInteger)index {
    DPArrayControllerSection *section = [self new];
    section.index = index;
    return section;
}

- (NSArray *)objects {
    [self removeDeletedObjectPlaceholders];
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
    return self.objects.count;
}

- (NSString *)name {
    return _name ?: @"";
}

#pragma mark - array mutating

- (void)setObjects:(NSArray *)objects {
    self.mutableObjects = [objects mutableCopy];
    self.deleteChanges = nil;
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index {
    [self removeDeletedObjectPlaceholders];
    
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
    id object = self.mutableObjects[index];
    [self.mutableObjects replaceObjectAtIndex:index withObject:[DPDeletedPlaceholderObject placeholderWithObject: object]];
    [self.deleteChanges addObject:@(index)];
}

- (void)replaceObjectWithObject:(id)object atIndex:(NSUInteger)index {
    [self removeDeletedObjectPlaceholders];
    [self.mutableObjects replaceObjectAtIndex:index withObject:object];
}

- (void)moveObjectAtIndex:(NSUInteger)index toIndex:(NSUInteger)newIndex {
    [self removeDeletedObjectPlaceholders];
    id object = self.mutableObjects[index];
    [self.mutableObjects removeObjectAtIndex:index];
    [self.mutableObjects insertObject:object atIndex:newIndex];
}

- (void)addObjectsFromArray:(NSArray *)otherArray {
    [self removeDeletedObjectPlaceholders];
    for (id object in otherArray) {
        [self insertObject:object atIndex:[self numberOfObjects]];
    }
}

- (NSUInteger)indexOfObject:(id)object {
    [self removeDeletedObjectPlaceholders];
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
    [self removeDeletedObjectPlaceholders];
    return [self.mutableObjects objectAtIndex:index];
}

- (void)removeDeletedObjectPlaceholders {
    [self.deleteChanges sortUsingSelector:@selector(compare:)];
    for (NSNumber *index in [self.deleteChanges reverseObjectEnumerator]) {
        [self.mutableObjects removeObjectAtIndex:index.integerValue];
    }
    self.deleteChanges = nil;
}

@end
