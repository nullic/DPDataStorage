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
#import "DelegateResponseMask.h"


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
        if ([delegate respondsToSelector:@selector(controllerWillChangeContent:)]) {
            responseMask |= ResponseMaskWillChangeContent;
        }
        if ([delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
            responseMask |= ResponseMaskDidChangeContent;
        }
        if ([delegate respondsToSelector:@selector(controller:didChangeSection:atIndex:forChangeType:)]) {
            responseMask |= ResponseMaskDidChangeSection;
        }
        if ([delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
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

- (void)applyPendingChanges {
    [self.sectionsStorage applyPendingChanges];
    for (DPArrayControllerSection *section in self.sectionsStorage.objects) {
        [section applyPendingChanges];
    }
}

#pragma mark - Notifications

- (void)managedObjectContextObjectsDidChange:(NSNotification *)notification {
    dispatch_block_t action = ^{
        NSDictionary *userInfo = notification.userInfo;

        NSArray *deletedPaths = [self pathsForObjects:userInfo[NSDeletedObjectsKey] sortComparator:inverseCompare];
        NSArray *updatedPaths = [self pathsForObjects:userInfo[NSUpdatedObjectsKey] sortComparator:inverseCompare];
        NSArray *refreshedPaths = [self pathsForObjects:userInfo[NSRefreshedObjectsKey] sortComparator:inverseCompare];

        BOOL hasChanges = (deletedPaths.count > 0) || (updatedPaths.count > 0) || (refreshedPaths.count > 0);

        if (hasChanges) {
            [self startUpdating];
            
            for (NSIndexPath *indexPath in deletedPaths) {
                [self deleteObjectAtIndextPath:indexPath];
            }

            for (NSIndexPath *indexPath in updatedPaths) {
                [self reloadObjectAtIndextPath:indexPath];
            }

            for (NSIndexPath *indexPath in refreshedPaths) {
                [self reloadObjectAtIndextPath:indexPath];
            }

            [self endUpdating];
        }
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
        NSIndexPath *path = [self indexPathForManagedObject:object];
        path ? [paths addObject:path] : nil;
    }
    comparator ? [paths sortUsingComparator:comparator] : nil;

    return paths;
}

#pragma mark - Editing: Items

- (void)removeAllObjects {
    [self removeAllObjectsImmediately:self.isUpdating == NO];
    if (self.isUpdating == NO) {
        [self applyPendingChanges];
    }
}

- (void)removeAllObjectsImmediately:(BOOL)immediately {
    if ([self.sectionsStorage numberOfObjects]) {
        for (NSUInteger section = [self.sectionsStorage numberOfObjects]; section > 0; section--) {
            [self removeSectionAtIndex:(section - 1) immediately:immediately];
        }
    }

    [self applyChanges];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
}

- (void)insertObject:(id)object atIndextPath:(NSIndexPath *)indexPath {
    [self insertObject:object atIndextPath:indexPath immediately:self.isUpdating == NO];
    if (self.isUpdating == NO) {
        [self applyPendingChanges];
    }
}

- (void)insertObject:(id)object atIndextPath:(NSIndexPath *)indexPath immediately:(BOOL)immediately {
    NSParameterAssert(indexPath != nil);
    NSParameterAssert(object != nil);
    
    if (immediately == NO) {
        [self.changes addObject:[DPItemChange insertObject:object atIndexPath:indexPath]];
    }
    else {
        DPArrayControllerSection *sectionInfo = [self.sectionsStorage objectAtIndex:[indexPath indexAtPosition:0]];
        [sectionInfo insertObject:object atIndex:[indexPath indexAtPosition:1]];

        if ([object isKindOfClass:[NSManagedObject class]]) {
            NSManagedObjectContext *context = [object managedObjectContext];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:context];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:context];
        }
    }
}

- (void)deleteObjectAtIndextPath:(NSIndexPath *)indexPath {
    [self deleteObjectAtIndextPath:indexPath immediately:self.isUpdating == NO];
    if (self.isUpdating == NO) {
        [self applyPendingChanges];
    }
}

- (void)deleteObjectAtIndextPath:(NSIndexPath *)indexPath immediately:(BOOL)immediately {
    NSParameterAssert(indexPath != nil);

    if (immediately == NO) {
        id object = [self objectAtIndexPath:indexPath];
        [self.changes addObject:[DPItemChange deleteObject:object atIndexPath:indexPath]];
    }
    else {
        DPArrayControllerSection *sectionInfo = [self.sectionsStorage objectAtIndex:[indexPath indexAtPosition:0]];
        [sectionInfo removeObjectAtIndex:[indexPath indexAtPosition:1]];
    }
}

- (void)reloadObjectAtIndextPath:(NSIndexPath *)indexPath {
    [self reloadObjectAtIndextPath:indexPath immediately:self.isUpdating == NO];
    if (self.isUpdating == NO) {
        [self applyPendingChanges];
    }
}

- (void)reloadObjectAtIndextPath:(NSIndexPath *)indexPath immediately:(BOOL)immediately {
    NSParameterAssert(indexPath != nil);
    
    if (immediately == NO) {
        id object = [self objectAtIndexPath:indexPath];
        [self.changes addObject:[DPItemChange updateObject:object atIndexPath:indexPath newIndexPath:nil]];
    }
}

- (void)moveObjectAtIndextPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self moveObjectAtIndextPath:indexPath toIndexPath:newIndexPath immediately:self.isUpdating == NO];
    if (self.isUpdating == NO) {
        [self applyPendingChanges];
    }
}

- (void)moveObjectAtIndextPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath immediately:(BOOL)immediately {
    NSParameterAssert(indexPath != nil);
    NSParameterAssert(newIndexPath != nil);

    if (immediately == NO) {
        DPArrayControllerSection *sectionInfo = [self.sectionsStorage objectAtIndex:[indexPath indexAtPosition:0]];
        id object = [sectionInfo objectAtIndex:[indexPath indexAtPosition:1]];
        [self.changes addObject:[DPItemChange moveObject:object atIndexPath:indexPath newIndex:newIndexPath]];
    }
    else {
        DPArrayControllerSection *sectionInfo = [self.sectionsStorage objectAtIndex:[indexPath indexAtPosition:0]];
        if ([indexPath indexAtPosition:0] == [newIndexPath indexAtPosition:0]) {
            [sectionInfo moveObjectAtIndex:[indexPath indexAtPosition:1] toIndex:[newIndexPath indexAtPosition:1]];
        }
        else {
            id object = [sectionInfo objectAtIndex:[indexPath indexAtPosition:1]];
            [sectionInfo removeObjectAtIndex:[indexPath indexAtPosition:1]];
            sectionInfo = [self.sectionsStorage objectAtIndex:[newIndexPath indexAtPosition:0]];
            [sectionInfo insertObject:object atIndex:[newIndexPath indexAtPosition:1]];
        }
    }
}

#pragma mark - Editing: Sections

- (void)insertSectionAtIndex:(NSUInteger)index {
    [self insertSectionAtIndex:index immediately:self.isUpdating == NO];
    if (self.isUpdating == NO) {
        [self applyPendingChanges];
    }
}

- (void)insertSectionAtIndex:(NSUInteger)index immediately:(BOOL)immediately {
    if (immediately == NO) {
        [self.changes addObject:[DPSectionChange insertObject:[DPArrayControllerSection new] atIndex:index]];
    }
    else {
        [self.sectionsStorage insertObject:[DPArrayControllerSection new] atIndex:index];
    }
}

- (void)insertSectionObject:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)index {
    [self insertSectionObject:sectionInfo atIndex:index immediately:self.isUpdating == NO];
    if (self.isUpdating == NO) {
        [self applyPendingChanges];
    }
}

- (void)insertSectionObject:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)index immediately:(BOOL)immediately {
    if (immediately == NO) {
        [self.changes addObject:[DPSectionChange insertObject:sectionInfo atIndex:index]];
    }
    else {
        [self.sectionsStorage insertObject:sectionInfo atIndex:index];
    }
}

- (void)removeSectionAtIndex:(NSUInteger)index {
    [self removeSectionAtIndex:index immediately:self.isUpdating == NO];
    if (self.isUpdating == NO) {
        [self applyPendingChanges];
    }
}

- (void)removeSectionAtIndex:(NSUInteger)index immediately:(BOOL)immediately {
    if (immediately == NO) {
        [self.changes addObject:[DPSectionChange deleteObject:[self.sectionsStorage objectAtIndex:index] atIndex:index]];
    }
    else {
        [self.sectionsStorage removeObjectAtIndex:index];
    }
}

- (void)reloadSectionAtIndex:(NSUInteger)index {
    [self reloadSectionAtIndex:index immediately:self.isUpdating == NO];
    if (self.isUpdating == NO) {
        [self applyPendingChanges];
    }
}

- (void)reloadSectionAtIndex:(NSUInteger)index immediately:(BOOL)immediately {
    if (immediately == NO) {
        [self.changes addObject:[DPSectionChange updateObject:[self.sectionsStorage objectAtIndex:index] atIndex:index]];
    }
}

- (void)setSectionName:(NSString *)name atIndex:(NSUInteger)index {
    DPArrayControllerSection *section = [self.sectionsStorage objectAtIndex:index];
    section.name = name;
}

- (NSString *)sectionNameAtIndex:(NSUInteger)index {
    return [[self.sectionsStorage objectAtIndex:index] name];
}

#pragma mark - Editing: Complex

- (NSInteger)insertCountAtSection:(NSInteger)section {
    NSInteger result = 0;

    for (DPChange *change in self.changes.reverseObjectEnumerator) {
        if (change.isApplied == YES) break;
        if ([change isKindOfClass:[DPSectionChange class]] && [(DPSectionChange *)change index] <= section) break;
        if ([change isKindOfClass:[DPItemChange class]]) {
            result += [(DPItemChange *)change affectSectionCountAtIndex:section];
        }
    }

    return result;
}

- (void)removeAllObjectsAtSection:(NSUInteger)index {
    [self removeAllObjectsAtSection:index immediately:self.isUpdating == NO];
}

- (void)removeAllObjectsAtSection:(NSInteger)section immediately:(BOOL)immediately {
    if (immediately == NO) {
        NSInteger lastIndex = [self numberOfItemsInSection:section];
        for (NSInteger i = 0; i < lastIndex; i++) {
            NSIndexPath *ip = [[NSIndexPath indexPathWithIndex:section] indexPathByAddingIndex:i];
            [self.changes addObject:[DPItemChange deleteObject:[self objectAtIndexPath:ip] atIndexPath:ip]];
        }
    }
    else {
        DPArrayControllerSection *sectionInfo = [self.sectionsStorage objectAtIndex:section];
        for (NSInteger i = sectionInfo.objects.count; i > 0; i--) {
            NSInteger row = i - 1;
            [self deleteObjectAtIndextPath:[[NSIndexPath indexPathWithIndex:section] indexPathByAddingIndex:row]];
        }
    }
}

- (void)addObjects:(NSArray *)objects atSection:(NSInteger)section {
    [self addObjects:objects atSection:section immediately:self.isUpdating == NO];
}

- (void)addObjects:(NSArray *)objects atSection:(NSInteger)section immediately:(BOOL)immediately {
    NSParameterAssert(section >= 0);

    NSInteger firstIndex = [self numberOfItemsInSection:section] + [self insertCountAtSection:section];
    if (immediately == NO) {
        for (NSInteger i = 0; i < objects.count; i++) {
            NSIndexPath *ip = [[NSIndexPath indexPathWithIndex:section] indexPathByAddingIndex:firstIndex + i];
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

- (void)setObjects:(NSArray *)objects atSection:(NSInteger)section {
    [self setObjects:objects atSection:section immediately:self.isUpdating == NO];
    if (self.isUpdating == NO) {
        [self applyPendingChanges];
    }
}

- (void)setObjects:(NSArray *)newObjects atSection:(NSInteger)section immediately:(BOOL)immediately {
    if (section < [self.sectionsStorage numberOfObjects]) {
        if (newObjects.count == 0) {
            [self removeAllObjectsAtSection:section immediately:immediately];
        }
        else {
            [self removeAllObjectsAtSection:section immediately:immediately];
            [self addObjects:newObjects atSection:section immediately:immediately];
        }
    }
    else {
        [self insertSectionAtIndex:section immediately:immediately];
        if (immediately == YES) [self.sectionsStorage applyPendingChanges];
        [self addObjects:newObjects atSection:section immediately:immediately];
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
        [self notifyDelegate];
        
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
    BOOL lastIsSectionChange = [self.changes.firstObject isKindOfClass:[DPSectionChange class]];
    for (DPChange *change in self.changes) {
        BOOL isSectionChange = [change isKindOfClass:[DPSectionChange class]];
        if (isSectionChange == NO && lastIsSectionChange == YES) {
            [self.sectionsStorage applyPendingChanges];
        }

        [change applyTo:self];
        lastIsSectionChange = isSectionChange;
    }
    [self applyPendingChanges];
}

- (void)notifyDelegate {
    for (DPChange *change in self.changes) {
        [change notifyDelegateOfController:self];
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
    if (indexPath && [indexPath indexAtPosition:0] < [self numberOfSections] && [indexPath indexAtPosition:1] < [self numberOfItemsInSection:[indexPath indexAtPosition:0]]) {
        DPArrayControllerSection *sectionInfo = [self.sectionsStorage objectAtIndex:[indexPath indexAtPosition:0]];
        result = [sectionInfo objectAtIndex:[indexPath indexAtPosition:1]];
    }
    return result;
}

- (NSIndexPath * _Nullable)indexPathForObject:(id)object {
    NSIndexPath *result = nil;

    if (object) {
        for (NSInteger section = 0; section < [self.sectionsStorage numberOfObjects]; section++) {
            DPArrayControllerSection *sectionInfo = [self.sectionsStorage objectAtIndex:section];
            NSInteger index = [sectionInfo indexOfObject:object];
            if (index != NSNotFound) {
                result = [[NSIndexPath indexPathWithIndex:section] indexPathByAddingIndex:index];
                break;
            }
        }
    }

    return result;
}

- (NSIndexPath * _Nullable)indexPathForManagedObject:(NSManagedObject *)object {
    NSIndexPath *result = nil;

    if (object) {
        for (NSInteger section = 0; section < [self.sectionsStorage numberOfObjects]; section++) {
            DPArrayControllerSection *sectionInfo = [self.sectionsStorage objectAtIndex:section];
            NSInteger index = [sectionInfo indexOfManagedObject:object];
            if (index != NSNotFound) {
                result = [[NSIndexPath indexPathWithIndex:section] indexPathByAddingIndex:index];
                break;
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
