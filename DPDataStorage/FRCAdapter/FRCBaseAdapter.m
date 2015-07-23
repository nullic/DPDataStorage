//
//  FRCBaseAdapter.m
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 27/04/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "FRCBaseAdapter.h"
#import "DPDataStorage.h"
#import <UIKit/UITableView.h>


@implementation NSFetchedResultsController (CommonFetchedResultsController)
@end

@implementation FRCBaseAdapter

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.listController.delegate == self) self.listController.delegate = nil;
}

- (void)awakeFromNib {
    if (self.listController == nil) {
        [self resetListController];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultStorageDidChange:) name:DPDataStorageDefaultStorageDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tempalateDidChange:) name:DPDataStorageFetchRequestTemplateDidChangeNotification object:nil];
    }
    return self;
}

#pragma mark -

- (void)defaultStorageDidChange:(NSNotification *)notification {
    [self resetListController];
}

- (void)tempalateDidChange:(NSNotification *)notification {
    NSString *templateName = notification.userInfo[DPDataStorageNotificationNameKey];
    if ([self.fetchRequestTemplateName isEqualToString:templateName]) {
        [self resetListController];
    }
}

- (void)resetListController {
    if ([DPDataStorage defaultStorage] != nil && self.fetchRequestTemplateName) {
        NSFetchedResultsController *controller = nil;

        NSManagedObjectContext *context = [[DPDataStorage defaultStorage] mainContext];
        NSFetchRequest *request = [[[DPDataStorage defaultStorage] managedObjectModel] fetchRequestFromTemplateWithName:self.fetchRequestTemplateName substitutionVariables:@{}];

        if (request) {
            NSError *error = nil;
            NSString *sectionNameKeyPath = (self.sectionNameKeyPath.length > 0) ? self.sectionNameKeyPath : nil;
            NSString *cacheName = (self.cacheName.length > 0) ? self.cacheName : nil;
            
            controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:sectionNameKeyPath cacheName:cacheName];
            [controller performFetch:&error];
            FAIL_ON_ERROR(error);
        }

        if (self.listController.delegate == self) self.listController.delegate = nil;
        self.listController = controller;
        self.listController.delegate = self;
    }
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
