//
//  MOArrayController.m
//  Commentator
//
//  Created by Dmitriy Petrusevich on 23/07/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "MOArrayController.h"

#pragma mark - MOArraySection

@interface MOArraySection : NSObject  <NSFetchedResultsSectionInfo>
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *indexTitle;
@property (nonatomic, readonly) NSUInteger numberOfObjects;
@property (nonatomic, strong) NSMutableArray *objects;
@end

@implementation MOArraySection

- (NSMutableArray *)objects {
    if (_objects == nil) _objects = [NSMutableArray new];
    return _objects;
}

- (NSString *)description {return [NSString stringWithFormat:@"%@ {numberOfObjects: %lu}", [super description], (unsigned long)self.numberOfObjects];}
- (NSString *)name {return nil;}
- (NSString *)indexTitle {return nil;}
- (NSUInteger)numberOfObjects {return self.objects.count;};

@end

#pragma mark - MOArrayController

NS_OPTIONS(NSUInteger, ResponseMask) {
    ResponseMaskDidChangeObject = 1 << 0,
    ResponseMaskDidChangeSection = 1 << 1,
    ResponseMaskWillChangeContent = 1 << 2,
    ResponseMaskDidChangeContent = 1 << 3,
};

@interface MOArrayController ()
@property (nonatomic, strong) NSMutableArray *sections; // @[<NSFetchedResultsSectionInfo>]
@property (nonatomic, assign) NSInteger updating;
@property (nonatomic, assign) enum ResponseMask responseMask;
@end

@implementation MOArrayController

- (instancetype)initWithDelegate:(id<CommonFetchedResultsControllerDelegate>)delegate {
    if ((self = [super init])) {
        self.delegate = delegate;
        self.sections = [NSMutableArray new];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

- (void)setDelegate:(id<CommonFetchedResultsControllerDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;

        enum ResponseMask responseMask = 0;
        if ([self.delegate respondsToSelector:@selector(controllerWillChangeContent:)]) {
            responseMask |= ResponseMaskWillChangeContent;
        }
        if ([self.delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
            responseMask |= ResponseMaskDidChangeContent;
        }
        if ([self.delegate respondsToSelector:@selector(controller:didChangeSection:atIndex:forChangeType:)]) {
            responseMask |= ResponseMaskDidChangeSection;
        }
        if ([self.delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
            responseMask |= ResponseMaskDidChangeObject;
        }

        self.responseMask = responseMask;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)managedObjectContextDidSave:(NSNotification *)notification {
    dispatch_block_t action = ^{
        NSDictionary *userInfo = notification.userInfo;

        NSComparator inverseCompare = ^NSComparisonResult(NSIndexPath *obj1, NSIndexPath *obj2) {
            NSComparisonResult result = [obj1 compare:obj2];
            if (result == NSOrderedAscending) result = NSOrderedDescending;
            else if (result == NSOrderedDescending) result = NSOrderedAscending;
            return result;
        };


        NSArray *deletedPaths = [self pathsForObjects:userInfo[NSDeletedObjectsKey] sortComparator:inverseCompare];
        if (deletedPaths.count > 0) {
            [self startUpdating];
            for (NSIndexPath *indexPath in deletedPaths) {
                [self deleteObjectAtIndextPath:indexPath];
            }
            [self endUpdating];
        }


        NSArray *updatedPaths = [self pathsForObjects:userInfo[NSUpdatedObjectsKey] sortComparator:inverseCompare];
        if (updatedPaths.count > 0) {
            [self startUpdating];
            for (NSIndexPath *indexPath in updatedPaths) {
                [self reloadObjectAtIndextPath:indexPath];
            }
            [self endUpdating];
        }
    };
    
    [NSThread isMainThread] ? action() : dispatch_async(dispatch_get_main_queue(), action);
}

- (NSArray *)pathsForObjects:(id<NSFastEnumeration>)collection sortComparator:(NSComparator)comparator {
    NSMutableArray *paths = [NSMutableArray new];
    for (NSManagedObject *object in collection) {
        NSIndexPath *path = [self indexPathForObject:object];
        path ? [paths addObject:path] : nil;
    }
    comparator ? [paths sortedArrayUsingComparator:comparator] : nil;

    return paths;
}

#pragma mark -

- (void)removeAllObjects {
    if (self.sections.count) {
        [self startUpdating];

        for (NSUInteger section = self.sections.count; section > 0; section--) {
            [self removeSectionAtIndex:(section - 1)];
        }

        [self endUpdating];
    }
}

- (void)insertObject:(NSManagedObject *)object atIndextPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath != nil);

    if (object != nil) {
        [self startUpdating];
        [self createSectionAtIndex:indexPath.section];

        MOArraySection *sectionInfo = self.sections[indexPath.section];
        [sectionInfo.objects insertObject:object atIndex:indexPath.row];

        if (self.responseMask & ResponseMaskDidChangeObject) {
            [self.delegate controller:self didChangeObject:object atIndexPath:nil forChangeType:NSFetchedResultsChangeInsert newIndexPath:indexPath];
        }

        [self endUpdating];
    }
}

- (void)deleteObjectAtIndextPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath != nil);

    [self startUpdating];

    MOArraySection *sectionInfo = self.sections[indexPath.section];
    id object = sectionInfo.objects[indexPath.row];
    [sectionInfo.objects removeObjectAtIndex:indexPath.row];

    if (self.responseMask & ResponseMaskDidChangeObject) {
        [self.delegate controller:self didChangeObject:object atIndexPath:indexPath forChangeType:NSFetchedResultsChangeDelete newIndexPath:nil];
    }

    [self endUpdating];
}

- (void)reloadObjectAtIndextPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath != nil);

    [self startUpdating];

    MOArraySection *sectionInfo = self.sections[indexPath.section];
    NSManagedObject *object = sectionInfo.objects[indexPath.row];
    [object.managedObjectContext refreshObject:object mergeChanges:YES];

    if (self.responseMask & ResponseMaskDidChangeObject) {
        [self.delegate controller:self didChangeObject:object atIndexPath:indexPath forChangeType:NSFetchedResultsChangeUpdate newIndexPath:nil];
    }

    [self endUpdating];
}

- (void)addObjects:(NSArray *)objects atSection:(NSInteger)section {
    NSParameterAssert(section >= 0);

    if (objects.count > 0) {
        [self startUpdating];
        [self createSectionAtIndex:section];

        if (self.responseMask & ResponseMaskDidChangeObject) {
            for (id object in objects) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.sections[section] numberOfObjects] inSection:section];
                [self insertObject:object atIndextPath:indexPath];
            }
        }
        else {
            MOArraySection *sectionInfo = self.sections[section];
            [sectionInfo.objects addObjectsFromArray:objects];
        }

        [self endUpdating];
    }
}

#pragma mark -

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    MOArraySection *sectionInfo = self.sections[indexPath.section];
    return sectionInfo.objects[indexPath.row];
}

- (NSIndexPath *)indexPathForObject:(id)object {
    NSIndexPath *result = nil;

    for (NSInteger section = 0; section < self.sections.count; section++) {
        MOArraySection *sectionInfo = self.sections[section];
        NSInteger index = [sectionInfo.objects indexOfObject:object];

        if (index != NSNotFound) {
            result = [NSIndexPath indexPathForItem:index inSection:section];
            break;
        }
    }

    return result;
}

#pragma mark - Updating

- (void)startUpdating {
    if (self.updating == 0) {
        if (self.responseMask & ResponseMaskWillChangeContent) {
            [self.delegate controllerWillChangeContent:self];
        }
    }
    self.updating++;
}

- (void)endUpdating {
    self.updating--;
    if (self.updating == 0) {
        if (self.responseMask & ResponseMaskDidChangeContent) {
            [self.delegate controllerDidChangeContent:self];
        }
    }
}

- (void)createSectionAtIndex:(NSUInteger)index {
    [self startUpdating];

    while (index >= self.sections.count) {
        MOArraySection *section = [MOArraySection new];
        [self.sections addObject:section];

        if (self.responseMask & ResponseMaskDidChangeSection) {
            [self.delegate controller:self didChangeSection:section atIndex:(self.sections.count - 1) forChangeType:NSFetchedResultsChangeInsert];
        }
    }

    [self endUpdating];
}

- (void)removeSectionAtIndex:(NSUInteger)index {
    [self startUpdating];

    MOArraySection *section = self.sections[index];
    [self.sections removeObjectAtIndex:index];

    if (self.responseMask & ResponseMaskDidChangeSection) {
        [self.delegate controller:self didChangeSection:section atIndex:index forChangeType:NSFetchedResultsChangeDelete];
    }

    [self endUpdating];
}

@end
