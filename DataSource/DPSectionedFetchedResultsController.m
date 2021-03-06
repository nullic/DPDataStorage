//
//  DPSectionedFetchedResultsController.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 1/9/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPSectionedFetchedResultsController.h"

@interface DPSectionedFetchedResultsController () <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *frc;
@end

@implementation DPSectionedFetchedResultsController

- (instancetype)initWithDelegate:(id<DataSourceContainerControllerDelegate> _Nullable)delegate sectionHashCalculator:(NSInteger (^)(id ))sectionHashCalculator sectionSortDescriptor:(NSSortDescriptor *)sectionSortDescriptor frc:(NSFetchedResultsController *)frc
{
    NSParameterAssert(frc.sectionNameKeyPath == nil);
    
    if (self = [super initWithDelegate:delegate sectionHashCalculator:sectionHashCalculator sectionSortDescriptor:sectionSortDescriptor]) {
        self.frc = frc;
        self.frc.delegate = self;
        [self.frc performFetch:nil];
        
        self.delegate = nil;
        [super setObjects:self.frc.sections.firstObject.objects];
        self.delegate = delegate;
    }

    return self;
}

- (void)managedObjectContextObjectsDidChange:(NSNotification *)notification {
    // Do Nothing, all changes should come from 'frc'
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
            [super insertObject:anObject atIndex:[newIndexPath indexAtPosition:1]];
            break;

        case NSFetchedResultsChangeDelete:
            [super removeObjectAtIndex:[indexPath indexAtPosition:1]];
            break;

        case NSFetchedResultsChangeUpdate:
            [super reloadObjectAtIndex:[indexPath indexAtPosition:1]];
            break;

        case NSFetchedResultsChangeMove:
            if ([newIndexPath isEqual:indexPath] == NO) {
                [super moveObjectAtIndex:[indexPath indexAtPosition:1] toIndex:[newIndexPath indexAtPosition:1]];
            }
            break;
    }
}

@end
