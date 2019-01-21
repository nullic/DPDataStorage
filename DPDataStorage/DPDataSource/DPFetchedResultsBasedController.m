//
//  DPFetchedResultsBasedController.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 1/21/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPFetchedResultsBasedController.h"

@interface DPFetchedResultsBasedController ()
@property (nonatomic, strong) NSFetchedResultsController *frc;
@end

@implementation DPFetchedResultsBasedController

- (instancetype)initWithDelegate:(id<DataSourceContainerControllerDelegate>)delegate frc:(NSFetchedResultsController *)frc {
    if ((self = [super initWithDelegate:nil])) {
        self.frc = frc;
        self.frc.delegate = self;
        [self.frc performFetch:nil];

        for (NSInteger i = 0; i < self.frc.sections.count; i++) {
            [super setObjects:self.frc.sections[i].objects atSection:i];
        }

        self.delegate = delegate;
    }
    return self;
}

#pragma mark - NSFetchedResultsController

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [super startUpdating];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [super endUpdating];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
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

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
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
