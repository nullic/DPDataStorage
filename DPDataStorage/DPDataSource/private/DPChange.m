//
//  DPArrayChange.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 3/7/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPChange.h"
#import "DPArrayController.h"
#import "DPArrayController+Private.h"
#import <UIKit/UIKit.h>

@implementation DPChange

- (instancetype)init {
    if (self = [super init]) {
        self.applied = NO;
        self.notified = NO;
    }
    return self;
}

- (void)applyTo:(DPArrayController *)controller {
    NSAssert(FALSE, @"Must be implemented in sub-classes");
}
- (void)notifyDelegateOfController:(DPArrayController *)controller {
    NSAssert(FALSE, @"Must be implemented in sub-classes");
}
@end


@implementation DPSectionChange

- (NSString *)description {
    NSString *typeString = @"";
    switch (self.type) {
        case NSFetchedResultsChangeInsert: typeString = @"NSFetchedResultsChangeInsert"; break;
        case NSFetchedResultsChangeDelete: typeString = @"NSFetchedResultsChangeDelete"; break;
        case NSFetchedResultsChangeMove: typeString = @"NSFetchedResultsChangeMove"; break;
        case NSFetchedResultsChangeUpdate: typeString = @"NSFetchedResultsChangeUpdate"; break;
    }

    return [NSString stringWithFormat:@"Section: %@ %@", typeString, @(self.index)];
}

+ (instancetype)changeObject:(id)anObject atIndex:(NSUInteger)index newIndex:(NSUInteger)newIndex forChangeType:(NSFetchedResultsChangeType)type {
    DPSectionChange *change = [self new];
    change.anObject = anObject;
    change.index = index;
    change.toIndex = newIndex;
    change.type = type;
    return change;
}

+ (instancetype)insertObject:(id)anObject atIndex:(NSUInteger)index {
    return [self changeObject:anObject atIndex:index newIndex:index forChangeType:NSFetchedResultsChangeInsert];
}

+ (instancetype)deleteObject:(id)anObject atIndex:(NSUInteger)index {
    return [self changeObject:anObject atIndex:index newIndex:-1 forChangeType:NSFetchedResultsChangeDelete];
}

+ (instancetype)updateObject:(id)anObject atIndex:(NSUInteger)index {
    return [self changeObject:anObject atIndex:index newIndex:index forChangeType:NSFetchedResultsChangeUpdate];
}

+ (instancetype)moveObject:(id)anObject atIndex:(NSUInteger)index newIndex:(NSUInteger)newIndex {
    return [self changeObject:anObject atIndex:index newIndex:newIndex forChangeType:NSFetchedResultsChangeMove];
}

- (void)applyTo:(DPArrayController *)controller {
    if (self.isApplied == YES) return;
    self.applied = YES;

    [controller setNextChangeType:self.type];
    
    switch (self.type) {
        case NSFetchedResultsChangeInsert:
            [controller insertSectionObject:self.anObject atIndex:self.index immediately:YES];
            break;
            
        case NSFetchedResultsChangeDelete:
            [controller removeSectionAtIndex:[controller.sections indexOfObject:self.anObject] immediately:YES];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [controller reloadSectionAtIndex:self.index immediately:YES];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
    }
}

- (void)notifyDelegateOfController:(DPArrayController *)controller {
    if (self.isNotified == YES) return;
    self.notified = YES;

    if ([controller delegateResponseToDidChangeSection]) {
        [controller.delegate controller:controller didChangeSection:self.anObject atIndex:self.index forChangeType:self.type];
    }
}

@end


#pragma mark -


@implementation DPItemChange

- (NSString *)description {
    NSString *typeString = @"";
    switch (self.type) {
        case NSFetchedResultsChangeInsert: typeString = @"NSFetchedResultsChangeInsert"; break;
        case NSFetchedResultsChangeDelete: typeString = @"NSFetchedResultsChangeDelete"; break;
        case NSFetchedResultsChangeMove: typeString = @"NSFetchedResultsChangeMove"; break;
        case NSFetchedResultsChangeUpdate: typeString = @"NSFetchedResultsChangeUpdate"; break;
    }
    
    return [NSString stringWithFormat:@"Item: %@ %@ -> %@", typeString, self.path, self.toPath];
}

+ (instancetype)changeObject:(id)anObject atIndexPath:(NSIndexPath *)path forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newPath {
    DPItemChange *change = [self new];
    change.anObject = anObject;
    change.path = path;
    change.type = type;
    change.toPath = newPath;
    return change;
}

+ (instancetype)insertObject:(id)anObject atIndexPath:(NSIndexPath *)path {
    NSParameterAssert(path != nil);
    return [self changeObject:anObject atIndexPath:nil forChangeType:NSFetchedResultsChangeInsert newIndexPath:path];
}

+ (instancetype)deleteObject:(id)anObject atIndexPath:(NSIndexPath *)path {
    NSParameterAssert(path != nil);
    return [self changeObject:anObject atIndexPath:path forChangeType:NSFetchedResultsChangeDelete newIndexPath:nil];
}

+ (instancetype)moveObject:(id)anObject atIndexPath:(NSIndexPath *)path newIndex:(NSIndexPath *)newPath {
    NSParameterAssert(path != nil);
    NSParameterAssert(newPath != nil);
    return [self changeObject:anObject atIndexPath:path forChangeType:NSFetchedResultsChangeMove newIndexPath:newPath];
}

+ (instancetype)updateObject:(id)anObject atIndexPath:(NSIndexPath *)path newIndexPath:(nullable NSIndexPath *)newPath {
    NSParameterAssert(path != nil);
    return [self changeObject:anObject atIndexPath:path forChangeType:NSFetchedResultsChangeUpdate newIndexPath:newPath];
}

- (NSInteger)affectSectionCountAtIndex:(NSInteger)index {
    switch (self.type) {
        case NSFetchedResultsChangeInsert:
            if (self.toPath.section == index) return 1;
            break;

        case NSFetchedResultsChangeDelete:
            if (self.path.section == index) return -1;
            break;

        case NSFetchedResultsChangeUpdate:
            break;

        case NSFetchedResultsChangeMove: {
            if (self.path.section == self.toPath.section) return 0;
            if (self.toPath.section == index) return 1;
            if (self.path.section == index) return -1;
        }
    }
    return 0;
}

- (void)applyTo:(DPArrayController *)controller {
    if (self.isApplied == YES) return;
    self.applied = YES;

    [controller setNextChangeType:self.type];
    
    switch (self.type) {
        case NSFetchedResultsChangeInsert:
            [controller insertObject:self.anObject atIndextPath:self.toPath immediately:YES];
            break;
            
        case NSFetchedResultsChangeDelete:
            [controller deleteObjectAtIndextPath:self.path immediately:YES];
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove: {
            NSIndexPath *from = [controller indexPathForObject:self.anObject];
            if (from != nil) {
                [controller moveObjectAtIndextPath:from toIndexPath:self.toPath immediately:YES];
            }
            else {
                [controller insertObject:self.anObject atIndextPath:self.toPath];
            }
            break;
        }
    }
}

- (void)notifyDelegateOfController:(DPArrayController *)controller {
    if (self.isNotified == YES) return;
    self.notified = YES;

    if ([controller delegateResponseToDidChangeObject]) {
        if (self.type == NSFetchedResultsChangeUpdate) {
            [controller.delegate controller:controller didChangeObject:self.anObject atIndexPath:self.path forChangeType:self.type newIndexPath:[controller indexPathForObject:self.anObject]];
        }
        else {
            [controller.delegate controller:controller didChangeObject:self.anObject atIndexPath:self.path forChangeType:self.type newIndexPath:self.toPath];
        }
    }
}

@end

