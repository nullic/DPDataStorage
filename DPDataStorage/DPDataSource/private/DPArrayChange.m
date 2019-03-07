//
//  DPArrayChange.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 3/7/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPArrayChange.h"
#import <UIKit/UIKit.h>

@interface DPArrayChange ()
@property (nonatomic, readwrite, assign) NSUInteger index;
@property (nonatomic, readwrite, assign) NSUInteger newIndex;
@property (nonatomic, readwrite, strong) id anObject;
@property (nonatomic, readwrite, assign) NSFetchedResultsChangeType type;
@end

@implementation DPArrayChange

+ (instancetype)changeObject:(id)anObject atIndex:(NSUInteger)index forChangeType:(NSFetchedResultsChangeType)type newIndex:(NSUInteger)newIndex {
    DPArrayChange *change = [self new];
    change.anObject = anObject;
    change.index = index;
    change.type = type;
    change.newIndex = newIndex;
    return change;
}

+ (instancetype)insertObject:(id)anObject atIndex:(NSUInteger)index {
    return [self changeObject:anObject atIndex:NSNotFound forChangeType:NSFetchedResultsChangeInsert newIndex:index];
}

+ (instancetype)deleteObject:(id)anObject atIndex:(NSUInteger)index {
    return [self changeObject:anObject atIndex:index forChangeType:NSFetchedResultsChangeDelete newIndex:NSNotFound];
}

+ (instancetype)moveObject:(id)anObject atIndex:(NSUInteger)index newIndex:(NSUInteger)newIndex {
    return [self changeObject:anObject atIndex:index forChangeType:NSFetchedResultsChangeMove newIndex:newIndex];
}

+ (instancetype)updateObject:(id)anObject atIndex:(NSUInteger)index {
    return [self changeObject:anObject atIndex:index forChangeType:NSFetchedResultsChangeUpdate newIndex:NSNotFound];
}

- (void)sendChangeTo:(id<DataSourceContainerControllerDelegate>)delegate sectionIndex:(NSUInteger)section controller:(id<DataSourceContainerController>)controller {

    NSIndexPath *atIndexPath = [NSIndexPath indexPathForRow:self.index inSection:section];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.newIndex inSection:section];

    switch (self.type) {
        case NSFetchedResultsChangeInsert:
            [delegate controller:controller didChangeObject:self.anObject atIndexPath:nil forChangeType:self.type newIndexPath:newIndexPath];
            break;

        case NSFetchedResultsChangeDelete:
            [delegate controller:controller didChangeObject:self.anObject atIndexPath:atIndexPath forChangeType:self.type newIndexPath:nil];
            break;

        case NSFetchedResultsChangeUpdate:
            [delegate controller:controller didChangeObject:self.anObject atIndexPath:atIndexPath forChangeType:self.type newIndexPath:nil];
            break;

        case NSFetchedResultsChangeMove:
            [delegate controller:controller didChangeObject:self.anObject atIndexPath:atIndexPath forChangeType:self.type newIndexPath:newIndexPath];
            break;
    }
}

- (void)sendSectionChangeTo:(id<DataSourceContainerControllerDelegate>)delegate controller:(id<DataSourceContainerController>)controller {
    switch (self.type) {
        case NSFetchedResultsChangeInsert:
            [delegate controller:controller didChangeSection:self.anObject atIndex:self.newIndex forChangeType:self.type];
            break;

        case NSFetchedResultsChangeDelete:
            [delegate controller:controller didChangeSection:self.anObject atIndex:self.index forChangeType:self.type];
            break;

        case NSFetchedResultsChangeUpdate:
            [delegate controller:controller didChangeSection:self.anObject atIndex:self.index forChangeType:self.type];
            break;

        case NSFetchedResultsChangeMove:
            [delegate controller:controller didChangeSection:self.anObject atIndex:self.index forChangeType:self.type];
            [delegate controller:controller didChangeSection:self.anObject atIndex:self.newIndex forChangeType:self.type];
            break;
    }
}

@end
