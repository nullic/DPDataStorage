//
//  DPTypedContainerController.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 9/13/19.
//  Copyright © 2019 dmitriy.petrusevich. All rights reserved.
//

#import "DPTypedContainerController.h"

@interface DPTypedContainerController()
@property (nonatomic, strong) id<DataSourceContainerController> container;
@end

@implementation DPTypedContainerController

- (instancetype)initWithContainer:(id<DataSourceContainerController>)container {
    if (self = [super init]) {
        self.container = container;
    }
    return self;
}

#pragma mark -

- (id<DataSourceContainerControllerDelegate>)delegate {
    return self.container.delegate;
}

- (void)setDelegate:(id<DataSourceContainerControllerDelegate>)delegate {
    self.container.delegate = delegate;
}

- (NSArray<id<NSFetchedResultsSectionInfo>> *)sections {
    return [self.container sections];
}

- (BOOL)hasData {
    return [self.container hasData];
}

- (NSArray *)fetchedObjects {
    return [self.container fetchedObjects];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.container objectAtIndexPath:indexPath];
}

- (NSIndexPath * _Nullable)indexPathForObject:(id)object {
    return [self.container indexPathForObject:object];
}

- (NSInteger)numberOfSections {
    return [self.container numberOfSections];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return [self.container numberOfItemsInSection:section];
}

@end
