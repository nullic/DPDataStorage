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
@end


@implementation DPArrayControllerSection
@synthesize name = _name;

- (instancetype)init {
    if ((self = [super init])) {
        _isInserted = YES;
    }
    return  self;
}

- (NSArray *)objects {
    return self.mutableObjects;
}

- (NSMutableArray *)mutableObjects {
    if (_mutableObjects == nil) _mutableObjects = [NSMutableArray new];
    return _mutableObjects;
}

- (NSString *)description {return [NSString stringWithFormat:@"%@ {numberOfObjects: %lu}", [super description], (unsigned long)self.numberOfObjects];}
- (NSUInteger)numberOfObjects {return self.objects.count;};
- (NSString *)name {return _name ?: @"";}

#pragma mark - array mutating

- (void)setObjects:(NSArray *)objects {
    self.mutableObjects = [objects mutableCopy];
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

    [self.mutableObjects insertObject:object atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [self.mutableObjects replaceObjectAtIndex:index withObject:[DPDeletedPlaceholderObject new]];
}

- (void)moveObjectAtIndex:(NSUInteger)index toIndex:(NSUInteger)newIndex {
    id object = self.mutableObjects[index];
    [self.mutableObjects removeObjectAtIndex:index];
    [self.mutableObjects insertObject:object atIndex:newIndex];
}

- (void)addObjectsFromArray:(NSArray *)otherArray {
    [self.mutableObjects addObjectsFromArray:otherArray];
}

- (NSUInteger)indexOfObject:(id)object {
    return [self.mutableObjects indexOfObject:object];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [self.mutableObjects objectAtIndex:index];
}

- (void)removeDeletedPlaceholderObjects {
    NSInteger count = self.mutableObjects.count;
    for (NSInteger i = (count - 1); i>= 0; i--) {
        if ([self.mutableObjects[i] isKindOfClass:[DPDeletedPlaceholderObject class]]) {
            [self.mutableObjects removeObjectAtIndex:i];
        }
    }
}
@end
