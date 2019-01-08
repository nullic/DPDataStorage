//
//  DPSectionedArrayController.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 1/8/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPSectionedArrayController.h"

@implementation DPSectionedArrayController

- (instancetype)initWithDelegate:(id<DataSourceContainerControllerDelegate> _Nullable)delegate sectionKeyPath:(NSString *)sectionKeyPath sectionSortDescriptor:(NSSortDescriptor *)sectionSortDescriptor
{
    self.sectionKeyPath = sectionKeyPath;
    self.sectionSortDescriptor = sectionSortDescriptor;
    return [super initWithDelegate:delegate];
}

#pragma mark -

- (void)setObjects:(NSArray *)objects {
    [self startUpdating];

    if (objects.count > 0) {
        NSArray *sortedObjects = [objects sortedArrayUsingDescriptors:@[self.sectionSortDescriptor]];
        NSMutableArray *sectionObjects = [NSMutableArray arrayWithObject:sortedObjects.firstObject];
        NSInteger sectionIndex = 0;

        NSComparator sectionComarator = ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [@([objects indexOfObject:obj1]) compare:@([objects indexOfObject:obj2])];
        };

        for (NSInteger i = 1; i < sortedObjects.count; i++) {
            if (self.sectionSortDescriptor.comparator(sortedObjects[i-1], sortedObjects[i]) != NSOrderedSame) {
                [sectionObjects sortUsingComparator:sectionComarator];
                [super setObjects:sectionObjects atSection:sectionIndex];
                if (self.sectionKeyPath.length > 0) {
                    NSString *name = [[sectionObjects.firstObject valueForKeyPath:self.sectionKeyPath] description];
                    [self setSectionName:name atIndex:sectionIndex];
                }

                sectionObjects = [NSMutableArray array];
                sectionIndex++;
            }

            [sectionObjects addObject:sortedObjects[i]];
        }

        [super setObjects:sectionObjects atSection:sectionIndex];

        // Remove old sections
        while ((sectionIndex + 1) < [self numberOfSections]) {
            [super removeSectionAtIndex:sectionIndex + 1];
        }
    }
    else {
        [self removeAllObjects];
    }

    [self endUpdating];
}

@end
