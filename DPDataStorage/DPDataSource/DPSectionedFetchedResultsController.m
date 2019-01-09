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

- (instancetype)initWithDelegate:(id<DataSourceContainerControllerDelegate> _Nullable)delegate sectionKeyPath:(NSString * _Nullable)sectionKeyPath sectionSortDescriptor:(NSSortDescriptor *)sectionSortDescriptor frc:(NSFetchedResultsController *)frc
{
    NSParameterAssert(frc.sectionNameKeyPath == nil);
    
    if (self = [super initWithDelegate:delegate sectionKeyPath:sectionKeyPath sectionSortDescriptor:sectionSortDescriptor]) {
        self.frc = frc;
        self.frc.delegate = self;
        [self.frc performFetch:nil];
        
        [super setObjects:self.frc.sections.firstObject.objects];
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
            [super insertObject:anObject atIndex:newIndexPath.item];
            break;

        case NSFetchedResultsChangeDelete:
             [super removeObjectAtIndex:indexPath.item];
            break;

        case NSFetchedResultsChangeUpdate:
            [super reloadObjectAtIndex:indexPath.item];
            break;

        case NSFetchedResultsChangeMove:
            if ([newIndexPath isEqual:indexPath] == NO) {
                [super moveObjectAtIndex:indexPath.item toIndex:newIndexPath.item];
            }
            break;
    }
}

@end
