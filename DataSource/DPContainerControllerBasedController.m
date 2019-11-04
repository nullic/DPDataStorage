//
//  DPContainerControllerBasedController.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 1/21/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPContainerControllerBasedController.h"
#import <CoreData/CoreData.h>
#import "DelegateResponseMask.h"

@interface DPContainerControllerBasedController ()
@property (nonatomic, strong) id<DataSourceContainerController> controller;
@property (nonatomic, assign) enum ResponseMask secondaryResponseMask;
@end

@implementation DPContainerControllerBasedController

- (instancetype)initWithDelegate:(id<DataSourceContainerControllerDelegate> _Nullable)delegate otherController:(id<DataSourceContainerController>)controller {
    if ((self = [super initWithDelegate:nil])) {
        self.controller = controller;
        self.controller.delegate = self;

        if ([controller isKindOfClass:[NSFetchedResultsController class]]) {
            [(NSFetchedResultsController *)controller performFetch:nil];
        }

        for (NSInteger i = 0; i < self.controller.sections.count; i++) {
            [super setObjects:self.controller.sections[i].objects atSection:i];
        }

        self.delegate = delegate;
    }
    return self;
}

- (void)setSecondaryDelegate:(id<DataSourceContainerControllerDelegate>)delegate {
    if (_secondaryDelegate != delegate) {
        _secondaryDelegate = delegate;

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

        self.secondaryResponseMask = responseMask;
    }
}

- (void)managedObjectContextObjectsDidChange:(NSNotification *)notification {}

#pragma mark - NSFetchedResultsController

- (void)controllerWillChangeContent:(id<DataSourceContainerController>)controller {
    [super startUpdating];
    if (self.secondaryResponseMask & ResponseMaskWillChangeContent) {
        [self.secondaryDelegate controllerWillChangeContent:self];
    }
}

- (void)controllerDidChangeContent:(id<DataSourceContainerController>)controller {
    [super endUpdating];
    if (self.secondaryResponseMask & ResponseMaskDidChangeContent) {
        [self.secondaryDelegate controllerDidChangeContent:self];
    }
}

- (void)controller:(id<DataSourceContainerController>)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [super insertObject:anObject atIndextPath:newIndexPath];
            break;

        case NSFetchedResultsChangeDelete:
            [super deleteObjectAtIndextPath:indexPath];
            break;

        case NSFetchedResultsChangeUpdate:
            [super reloadObjectAtIndextPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [super moveObjectAtIndextPath:indexPath toIndexPath:newIndexPath];
            break;
    }

    if (self.secondaryResponseMask & ResponseMaskDidChangeObject) {
        [self.secondaryDelegate controller:self didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    }
}

- (void)controller:(id<DataSourceContainerController>)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [super insertSectionAtIndex:sectionIndex];
            break;

        case NSFetchedResultsChangeDelete:
            [super removeSectionAtIndex:sectionIndex];
            break;

        case NSFetchedResultsChangeUpdate:
            [super reloadSectionAtIndex:sectionIndex];
            break;

        default:
            break;
    }

    if (self.secondaryResponseMask & ResponseMaskDidChangeSection) {
        [self.secondaryDelegate controller:self didChangeSection:sectionInfo atIndex:sectionIndex forChangeType:type];
    }
}

@end
