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

- (NSString *)description {return [NSString stringWithFormat:@"%@ {numberOfObjects: %lu}", [super description], (unsigned long)self.numberOfObjects];}
- (NSUInteger)numberOfObjects {return self.objects.count;};
- (NSString *)name {return _name ?: @"";}

#pragma mark - array mutating

- (void)setObjects:(NSArray *)objects {
    self.mutableObjects = [objects mutableCopy];
    // TODO: add changes
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index {
    if (index > self.mutableObjects.count) {
        while (index >= self.mutableObjects.count) {
            [self.mutableObjects insertObject:[DPPlaceholderObject new] atIndex:self.mutableObjects.count];
        }
    }

    if (index < self.mutableObjects.count && [[self.mutableObjects objectAtIndex:index] isKindOfClass:[DPPlaceholderObject class]]) {
        [self.mutableObjects removeObjectAtIndex:index];
    }

    [self.mutableObjects insertObject:[DPInsertedPlaceholderObject placeholderWithObject: object] atIndex:index];
    [self.changes addObject:[DPArrayChange insertObject:object atIndex:index]];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    id object = self.mutableObjects[index];
    [self.mutableObjects replaceObjectAtIndex:index withObject:[DPDeletedPlaceholderObject placeholderWithObject: object]];
    [self.changes addObject:[DPArrayChange deleteObject:object atIndex:index]];
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
    [self.mutableObjects addObjectsFromArray:otherArray];
    // TODO: add changes
}

- (NSUInteger)indexOfObject:(id)object {
    return [self.mutableObjects indexOfObject:object];
}

- (id)objectAtIndex:(NSUInteger)index {
    id object = [self.mutableObjects objectAtIndex:index];
    return [object isKindOfClass:[DPPlaceholderObject class]] ? ([object anObject] ?: object)  : object;
}

- (void)removePlaceholderObjects {
    NSInteger count = self.mutableObjects.count;
    for (NSInteger i = (count - 1); i>= 0; i--) {
        if ([self.mutableObjects[i] isKindOfClass:[DPDeletedPlaceholderObject class]]) {
            [self.mutableObjects removeObjectAtIndex:i];
        }
        if ([self.mutableObjects[i] isKindOfClass:[DPInsertedPlaceholderObject class]]) {
            DPInsertedPlaceholderObject *placeholder = self.mutableObjects[i];
            [self.mutableObjects replaceObjectAtIndex:i withObject:[placeholder anObject]];
        }
    }
}

- (NSArray<DPArrayChange *> *)updateChanges {
    return [self changes];
}

@end
