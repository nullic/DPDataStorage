//
//  DPBaseDataSource.m
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 27/04/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "DPBaseDataSource.h"

@implementation NSFetchedResultsController (DataSourceContainerController)
@end

@implementation DPBaseDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    if (self.listController.delegate == self) self.listController.delegate = nil;
}

#pragma mark -

- (NSInteger)numberOfSections {
    return [[self.listController sections] count];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    NSInteger result = 0;
    if (section < [self numberOfSections] && section >= 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo =  [[self.listController sections] objectAtIndex:section];
        result = [sectionInfo numberOfObjects];
    }
    return result;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    id result = nil;
    if (indexPath.section < [self numberOfSections] && indexPath.row < [self numberOfItemsInSection:indexPath.section]) {
        result = [self.listController objectAtIndexPath:indexPath];
    }
    return result;
}

- (NSIndexPath *)indexPathForObject:(id)object {
    return object ? [self.listController indexPathForObject:object] : nil;
}

#pragma mark - Forward

- (BOOL)respondsToSelector:(SEL)selector {
    BOOL result = [super respondsToSelector:selector];
    return result ? result : [self.forwardDelegate respondsToSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([self.forwardDelegate respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.forwardDelegate];
    }
    else {
        [super forwardInvocation:invocation];
    }
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        signature = [self.forwardDelegate methodSignatureForSelector:selector];
    }
    return signature;
}

@end
