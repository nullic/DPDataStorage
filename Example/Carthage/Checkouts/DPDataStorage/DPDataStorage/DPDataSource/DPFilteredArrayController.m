//
//  DPFilteredArrayController.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 1/8/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPFilteredArrayController.h"

@implementation DPFilteredArrayController

- (BOOL)isObjectMatchFilter:(id)object {
    BOOL result = YES;
    if (self.filter) {
        if ([object isKindOfClass:[NSManagedObject class]]) {
            NSManagedObject *managedObject = object;

            NSManagedObjectContext *context = [managedObject managedObjectContext];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            request.entity = managedObject.entity;

            NSPredicate *selfPredicate = [NSPredicate predicateWithFormat:@"self == %@", [managedObject objectID]];
            request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[selfPredicate, self.filter]];
            request.fetchLimit = 1;

            result = ([context countForFetchRequest:request error:nil] > 0);
        }
        else {
            result = [self.filter evaluateWithObject:object];
        }
    }
    return result;
}

- (void)setFilter:(NSPredicate * _Nullable)filter {
    if (_filter != filter) {
        _filter = filter;

        if (filter != nil) {
            [self startUpdating];
            for (NSUInteger section = 0; section < self.sections.count; section++) {
                for (NSInteger i = [self numberOfItemsInSection:section]; i > 0; i--) {
                    NSInteger row = i - 1;
                    [self reloadObjectAtIndextPath:[[NSIndexPath indexPathWithIndex:section] indexPathByAddingIndex:row]];
                }
            }
            [self endUpdating];
        }
    }
}

#pragma mark - Overrides

- (void)insertObject:(id)object atIndextPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath != nil);

    if (object != nil && [self isObjectMatchFilter:object]) {
        [super insertObject:object atIndextPath:indexPath];
    }
}

- (void)addObjects:(NSArray *)objects atSection:(NSInteger)section {
    NSParameterAssert(section >= 0);

    if (self.filter) {
        NSMutableArray *filtedArray = [[NSMutableArray alloc] initWithCapacity:objects.count];
        for (id object in objects) {
            if ([self isObjectMatchFilter:object]) {
                [filtedArray addObject:object];
            }
        }

        [super addObjects:filtedArray atSection:section];
    }
    else {
        [super addObjects:objects atSection:section];
    }
}


- (void)reloadObjectAtIndextPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath != nil);

    id object = [self objectAtIndexPath:indexPath];

    if ([self isObjectMatchFilter:object] == YES) {
        [super reloadObjectAtIndextPath:indexPath];
    }
    else if (self.filter != nil) {
        [self deleteObjectAtIndextPath:indexPath];
    }
}

@end
