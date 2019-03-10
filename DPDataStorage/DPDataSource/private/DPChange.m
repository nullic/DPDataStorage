//
//  DPArrayChange.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 3/7/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPChange.h"
#import "DPArrayController.h"
#import <UIKit/UIKit.h>


@implementation DPChange
- (void)applyTo:(DPArrayController *)controller {
    NSAssert(FALSE, @"Must be implemented in sub-classes");
}

- (NSComparisonResult)compare:(DPChange *)other {
    if ([self isKindOfClass:[DPSectionChange class]] && [other isKindOfClass:[DPItemChange class]]) {
        return NSOrderedAscending;
    } else if ([self isKindOfClass:[DPItemChange class]] && [other isKindOfClass:[DPSectionChange class]]) {
        return NSOrderedDescending;
    } else if (self.type == other.type) {
        return NSOrderedSame;
    } else if (self.type == NSFetchedResultsChangeDelete)  {
        return NSOrderedAscending;
    } else if (other.type == NSFetchedResultsChangeDelete)  {
        return NSOrderedDescending;
    } else if (self.type == NSFetchedResultsChangeInsert)  {
        return NSOrderedAscending;
    } else if (other.type == NSFetchedResultsChangeInsert)  {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
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

+ (instancetype)changeObject:(id)anObject atIndex:(NSUInteger)index forChangeType:(NSFetchedResultsChangeType)type {
    DPSectionChange *change = [self new];
    change.anObject = anObject;
    change.index = index;
    change.type = type;
    return change;
}

+ (instancetype)insertObject:(id)anObject atIndex:(NSUInteger)index {
    return [self changeObject:anObject atIndex:index forChangeType:NSFetchedResultsChangeInsert];
}

+ (instancetype)deleteObject:(id)anObject atIndex:(NSUInteger)index {
    return [self changeObject:anObject atIndex:index forChangeType:NSFetchedResultsChangeDelete];
}

+ (instancetype)updateObject:(id)anObject atIndex:(NSUInteger)index {
    return [self changeObject:anObject atIndex:index forChangeType:NSFetchedResultsChangeUpdate];
}

- (void)applyTo:(DPArrayController *)controller {
    NSParameterAssert(controller.isUpdating == FALSE);
    
    if ([controller delegateResponseToDidChangeSection]) {
        [controller.delegate controller:controller didChangeSection:self.anObject atIndex:self.index forChangeType:self.type];
    }
    
    switch (self.type) {
        case NSFetchedResultsChangeInsert:
            [controller insertSectionObject:self.anObject atIndex:self.index];
            break;
            
        case NSFetchedResultsChangeDelete:
            [controller removeSectionAtIndex:self.index];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [controller reloadSectionAtIndex:self.index];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
    }
}

- (NSComparisonResult)compare:(DPChange *)other {
    NSComparisonResult result = [super compare:other];
    if (result == NSOrderedSame) {
        if (self.type == NSFetchedResultsChangeInsert) {
            
        } else if (self.type == NSFetchedResultsChangeInsert) {
        }
    }
    return result;
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
    return [self changeObject:anObject atIndexPath:nil forChangeType:NSFetchedResultsChangeInsert newIndexPath:path];
}

+ (instancetype)deleteObject:(id)anObject atIndexPath:(NSIndexPath *)path {
    return [self changeObject:anObject atIndexPath:path forChangeType:NSFetchedResultsChangeDelete newIndexPath:nil];
}

+ (instancetype)moveObject:(id)anObject atIndexPath:(NSIndexPath *)path newIndex:(NSIndexPath *)newPath {
    return [self changeObject:anObject atIndexPath:path forChangeType:NSFetchedResultsChangeMove newIndexPath:newPath];
}

+ (instancetype)updateObject:(id)anObject atIndexPath:(NSIndexPath *)path newIndexPath:(nullable NSIndexPath *)newPath {
    return [self changeObject:anObject atIndexPath:path forChangeType:NSFetchedResultsChangeUpdate newIndexPath:newPath];
}

- (void)applyTo:(DPArrayController *)controller {
    NSParameterAssert(controller.isUpdating == FALSE);
    
    if ([controller delegateResponseToDidChangeObject]) {
        [controller.delegate controller:controller didChangeObject:self.anObject atIndexPath:self.path forChangeType:self.type newIndexPath:self.toPath];
    }
    
    switch (self.type) {
        case NSFetchedResultsChangeInsert:
            [controller insertObject:self.anObject atIndextPath:self.toPath];
            break;
            
        case NSFetchedResultsChangeDelete:
            [controller deleteObjectAtIndextPath:self.path];
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            [controller moveObjectAtIndextPath:[controller indexPathForObject:self.anObject] toIndexPath:self.toPath];
            break;
    }
}

@end

