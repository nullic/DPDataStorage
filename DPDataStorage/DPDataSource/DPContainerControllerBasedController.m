//
//  DPContainerControllerBasedController.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 1/21/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPContainerControllerBasedController.h"
#import <CoreData/CoreData.h>

@interface DPContainerControllerBasedController ()
@property (nonatomic, strong) id<DataSourceContainerController> controller;
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

#pragma mark - NSFetchedResultsController

- (void)controllerWillChangeContent:(id<DataSourceContainerController>)controller {
    [super startUpdating];
}

- (void)controllerDidChangeContent:(id<DataSourceContainerController>)controller {
    [super endUpdating];
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
}

@end
