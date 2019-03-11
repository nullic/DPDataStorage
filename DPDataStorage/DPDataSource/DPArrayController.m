//
//  DPArrayController.m
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 23/07/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "DPArrayController.h"
#import "DPArrayControllerSection.h"
#import "DPChange.h"
#import "DPChange.h"
#import <CoreData/CoreData.h>


NS_OPTIONS(NSUInteger, ResponseMask) {
    ResponseMaskDidChangeObject = 1 << 0,
    ResponseMaskDidChangeSection = 1 << 1,
    ResponseMaskWillChangeContent = 1 << 2,
    ResponseMaskDidChangeContent = 1 << 3,
};


NS_ASSUME_NONNULL_BEGIN
static NSComparator inverseCompare = ^NSComparisonResult(NSIndexPath *obj1, NSIndexPath *obj2) {
    NSComparisonResult result = [obj1 compare:obj2];
    if (result == NSOrderedAscending) result = NSOrderedDescending;
    else if (result == NSOrderedDescending) result = NSOrderedAscending;
    return result;
};

@interface DPArrayController ()
@property (nonatomic, strong) DPArrayControllerSection *sectionsStorage;
@property (nonatomic, strong, null_resettable) NSMutableArray<DPChange *> *changes;

@property (nonatomic, assign) BOOL updating;
@property (nonatomic, assign) enum ResponseMask responseMask;
@end

@implementation DPArrayController

- (instancetype)initWithDelegate:(id<DataSourceContainerControllerDelegate> _Nullable)delegate {
    if ((self = [self init])) {
        self.delegate = delegate;
    }
    return self;
}

- (void)setDelegate:(id<DataSourceContainerControllerDelegate> _Nullable)delegate {
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

- (BOOL)delegateResponseToDidChangeObject {
    return self.responseMask & ResponseMaskDidChangeObject;
}

- (BOOL)delegateResponseToDidChangeSection {
    return self.responseMask & ResponseMaskDidChangeSection;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (DPArrayControllerSection *)sectionsStorage {
    if (_sectionsStorage == nil) _sectionsStorage = [DPArrayControllerSection new];
    return _sectionsStorage;
}

- (NSArray<DPArrayControllerSection *> *)sections {
    return [self.sectionsStorage objects];
}

- (NSMutableArray<DPChange *> *)changes {
    if (_changes == nil) _changes = [NSMutableArray new];
    return _changes;
}

#pragma mark - Notifications

- (void)managedObjectContextObjectsDidChange:(NSNotification *)notification {
    dispatch_block_t action = ^{
        NSDictionary *userInfo = notification.userInfo;

        NSArray *deletedPaths = [self pathsForObjects:userInfo[NSDeletedObjectsKey] sortComparator:inverseCompare];
        NSArray *updatedPaths = [self pathsForObjects:userInfo[NSUpdatedObjectsKey] sortComparator:inverseCompare];
        NSArray *refreshedPaths = [self pathsForObjects:userInfo[NSRefreshedObjectsKey] sortComparator:inverseCompare];

        BOOL hasChanges = (deletedPaths.count > 0) || (updatedPaths.count > 0) || (refreshedPaths.count > 0);

        if (hasChanges) [self startUpdating];

        for (NSIndexPath *indexPath in deletedPaths) {
            [self deleteObjectAtIndextPath:indexPath];
        }

        for (NSIndexPath *indexPath in updatedPaths) {
            [self reloadObjectAtIndextPath:indexPath];
        }

        for (NSIndexPath *indexPath in refreshedPaths) {
            [self reloadObjectAtIndextPath:indexPath];
        }

        if (hasChanges) [self endUpdating];
    };

    NSManagedObjectContext *context = notification.object;
    if (context.concurrencyType == NSMainQueueConcurrencyType && [NSThread isMainThread]) {
        [context performBlockAndWait:action];
    } else {
        [context performBlock:action];
    }
}

#pragma mark - Helper

- (NSArray *)pathsForObjects:(id<NSFastEnumeration>)collection sortComparator:(NSComparator)comparator {
    NSMutableArray *paths = [NSMutableArray new];
    for (id object in collection) {
        NSIndexPath *path = [self indexPathForObject:object];
        path ? [paths addObject:path] : nil;
    }
    comparator ? [paths sortUsingComparator:comparator] : nil;

    return paths;
}

#pragma mark - Editing: Items

- (void)removeAllObjects {
    if ([self.sectionsStorage numberOfObjects]) {
        for (NSUInteger section = [self.sectionsStorage numberOfObjects]; section > 0; section--) {
            [self removeSectionAtIndex:(section - 1)];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    }
}

- (void)insertObject:(id)object atIndextPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath != nil);
    NSParameterAssert(object != nil);
    
    if (self.isUpdating == YES) {
        [self.changes addObject:[DPItemChange insertObject:object atIndexPath:indexPath]];
    }
    else {
        DPArrayControllerSection *sectionInfo = [self.sectionsStorage objectAtIndex:indexPath.section];
        [sectionInfo insertObject:object atIndex:indexPath.row];

        if ([object isKindOfClass:[NSManagedObject class]]) {
            NSManagedObjectContext *context = [object managedObjectContext];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:context];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:context];
        }
    }
}

- (void)deleteObjectAtIndextPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath != nil);

    if (self.isUpdating == YES) {
        id object = [self objectAtIndexPath:indexPath];
        [self.changes addObject:[DPItemChange deleteObject:object atIndexPath:indexPath]];
    }
    else {
        DPArrayControllerSection *sectionInfo = [self.sectionsStorage objectAtIndex:indexPath.section];
        [sectionInfo removeObjectAtIndex:indexPath.row];
    }
}

- (void)reloadObjectAtIndextPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath != nil);
    
    if (self.isUpdating == YES) {
        id object = [self objectAtIndexPath:indexPath];
        [self.changes addObject:[DPItemChange updateObject:object atIndexPath:indexPath newIndexPath:nil]];
    }
}

- (void)moveObjectAtIndextPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    NSParameterAssert(indexPath != nil);
    NSParameterAssert(newIndexPath != nil);

    if ([indexPath isEqual:newIndexPath]) {
        [self reloadObjectAtIndextPath:indexPath];
        return;
    }
    
    if (self.isUpdating == YES) {
        DPArrayControllerSection *sectionInfo = [self.sectionsStorage objectAtIndex:indexPath.section];
        id object = [sectionInfo objectAtIndex:indexPath.row];
        [self.changes addObject:[DPItemChange moveObject:object atIndexPath:indexPath newIndex:newIndexPath]];
    }
    else {
        DPArrayControllerSection *sectionInfo = [self.sectionsStorage objectAtIndex:indexPath.section];
        if (indexPath.section == newIndexPath.section) {
            [sectionInfo moveObjectAtIndex:indexPath.row toIndex:newIndexPath.row];
        }
        else {
            id object = [sectionInfo objectAtIndex:indexPath.row];
            [sectionInfo removeObjectAtIndex:indexPath.row];
            sectionInfo = [self.sectionsStorage objectAtIndex:newIndexPath.section];
            [sectionInfo insertObject:object atIndex:newIndexPath.row];
        }
    }
}

#pragma mark - Editing: Sections

- (void)insertSectionAtIndex:(NSUInteger)index {
    if (self.isUpdating == YES) {
        [self.changes addObject:[DPSectionChange insertObject:[DPArrayControllerSection new] atIndex:index]];
    }
    else {
        [self.sectionsStorage insertObject:[DPArrayControllerSection new] atIndex:index];
    }
}

- (void)insertSectionObject:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)index {
    if (self.isUpdating == YES) {
        [self.changes addObject:[DPSectionChange insertObject:sectionInfo atIndex:index]];
    }
    else {
        [self.sectionsStorage insertObject:sectionInfo atIndex:index];
    }
}

- (void)removeSectionAtIndex:(NSUInteger)index {
    if (self.isUpdating == YES) {
        [self.changes addObject:[DPSectionChange deleteObject:[self.sectionsStorage objectAtIndex:index] atIndex:index]];
    }
    else {
        [self.sectionsStorage removeObjectAtIndex:index];
    }
}

- (void)reloadSectionAtIndex:(NSUInteger)index {
    if (self.isUpdating == YES) {
        [self.changes addObject:[DPSectionChange updateObject:[self.sectionsStorage objectAtIndex:index] atIndex:index]];
    }
    else {
        [self.sectionsStorage replaceObjectWithObject:[self.sectionsStorage objectAtIndex:index] atIndex:index];
    }
}

- (void)setSectionName:(NSString *)name atIndex:(NSUInteger)index {
    DPArrayControllerSection *section = [self.sectionsStorage objectAtIndex:index];
    section.name = name;
}

#pragma mark - Editing: Complex

- (void)removeAllObjectsAtSection:(NSInteger)section {
    if (self.isUpdating == YES) {
        NSInteger lastIndex = [self numberOfItemsInSection:section];
        for (NSInteger i = 0; i < lastIndex; i++) {
            NSIndexPath *ip = [NSIndexPath indexPathForItem:i inSection:section];
            [self.changes addObject:[DPItemChange deleteObject:[self objectAtIndexPath:ip] atIndexPath:ip]];
        }
    }
    else {
        DPArrayControllerSection *sectionInfo = [self.sectionsStorage objectAtIndex:section];
        for (NSInteger i = sectionInfo.objects.count; i > 0; i--) {
            NSInteger row = i - 1;
            [self deleteObjectAtIndextPath:[NSIndexPath indexPathForItem:row inSection:section]];
        }
    }
}

- (void)addObjects:(NSArray *)objects atSection:(NSInteger)section {
    NSParameterAssert(section >= 0);
    
    if (self.isUpdating == YES) {
        NSInteger firstIndex = [self numberOfItemsInSection:section];
        for (NSInteger i = 0; i < objects.count; i++) {
            NSIndexPath *ip = [NSIndexPath indexPathForItem:firstIndex + i inSection:section];
            [self.changes addObject:[DPItemChange insertObject:objects[i] atIndexPath:ip]];
        }
    }
    else {
        DPArrayControllerSection *sectionInfo = [self.sectionsStorage objectAtIndex:section];
        [sectionInfo addObjectsFromArray:objects];

        for (id object in objects) {
            if ([object isKindOfClass:[NSManagedObject class]]) {
                NSManagedObjectContext *context = [object managedObjectContext];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:context];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:context];
            }
        }
    }
}

- (void)setObjects:(NSArray *)newObjects atSection:(NSInteger)section {
    if (section < [self.sectionsStorage numberOfObjects]) {
        if (newObjects.count == 0) {
            [self removeAllObjectsAtSection:section];
        }
        else {
            [self removeAllObjectsAtSection:section];
            [self addObjects:newObjects atSection:section];
        }
    }
    else {
        [self insertSectionAtIndex:section];
        [self addObjects:newObjects atSection:section];
    }
}

#pragma mark - Updating

- (void)startUpdating {
    self.updating = YES;
}

- (void)endUpdating {
    self.updating = NO;
    
    if ([self hasChanges]) {
        // Start notify delegate
        if (self.responseMask & ResponseMaskWillChangeContent) {
            [self.delegate controllerWillChangeContent:self];
        }
        
        [self applyChanges];

        [self.sectionsStorage removeDeletedObjectPlaceholders];
        for (DPArrayControllerSection *section in self.sectionsStorage.objects) {
            [section removeDeletedObjectPlaceholders];
        }
        
        if (self.responseMask & ResponseMaskDidChangeContent) {
            [self.delegate controllerDidChangeContent:self];
        }
    }
    self.changes = nil;
}

- (BOOL)isUpdating {
    return self.updating;
}

- (BOOL)hasChanges {
    return [[self changes] count] > 0;
}

- (void)applyChanges {
    for (DPChange *change in self.changes) {
        [change applyTo:self];
    }
}

- (NSArray<DPChange *> *)updateChanges {
    return [self changes];
}

#pragma mark - Getters

- (NSInteger)numberOfSections {
    return [self.sectionsStorage numberOfObjects];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    NSInteger result = 0;
    if (section < [self.sectionsStorage numberOfObjects] && section >= 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.sectionsStorage objectAtIndex:section];
        result = [sectionInfo numberOfObjects];
    }
    return result;
}

- (BOOL)hasData {
    for (id <NSFetchedResultsSectionInfo> section in self.sections) {
        if ([section numberOfObjects] > 0) return YES;
    }
    return NO;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    id result = nil;
    if (indexPath && indexPath.section < [self numberOfSections] && indexPath.row < [self numberOfItemsInSection:indexPath.section]) {
        DPArrayControllerSection *sectionInfo = [self.sectionsStorage objectAtIndex:indexPath.section];
        result = [sectionInfo objectAtIndex:indexPath.row];
    }
    return result;
}

- (NSIndexPath * _Nullable)indexPathForObject:(id)object {
    NSIndexPath *result = nil;

    if (object) {
        id left = [object isKindOfClass:[NSManagedObject class]] ? [object objectID] : object;

        for (NSInteger section = 0; section < [self.sectionsStorage numberOfObjects]; section++) {
            DPArrayControllerSection *sectionInfo = [self.sectionsStorage objectAtIndex:section];
            
            for (NSInteger index = 0; index < [sectionInfo numberOfObjects]; index++) {
                id right = [sectionInfo objectAtIndex:index];
                right = [right isKindOfClass:[NSManagedObject class]] ? [right objectID] : right;

                if ([left isEqual:right]) {
                    result = [NSIndexPath indexPathForItem:index inSection:section];
                    break;
                }
            }
        }
    }

    return result;
}

- (NSArray *)fetchedObjects {
    NSMutableArray *fetchedObjects = [NSMutableArray array];
    for (id <NSFetchedResultsSectionInfo> section in self.sections) {
        [fetchedObjects addObjectsFromArray:section.objects];
    }
    return fetchedObjects;
}

@end

NS_ASSUME_NONNULL_END
