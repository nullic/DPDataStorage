//
//  NSManagedObjectContext+DataStorage.m
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 11/11/11.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "NSManagedObjectContext+DataStorage.h"
#import "NSManagedObjectModel+DataStorage.h"
#import "DPDataStorage.h"
#import <objc/runtime.h>


#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@implementation NSManagedObjectContext (DataStorage)

+ (NSManagedObjectContext *)mainContext {
    return [[DPDataStorage defaultStorage] mainContext];
}

+ (NSManagedObjectContext*)newManagedObjectContext {
    return [[DPDataStorage defaultStorage] newManagedObjectContext];
}

+ (NSManagedObjectContext*)newMainQueueManagedObjectContext {
    return [[DPDataStorage defaultStorage] newMainQueueManagedObjectContext];
}

+ (NSManagedObjectContext*)newPrivateQueueManagedObjectContext {
    return [[DPDataStorage defaultStorage] newPrivateQueueManagedObjectContext];
}

#pragma mark -

- (NSManagedObjectContext *)newChildManagedObjectContext {
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    managedObjectContext.parentContext = self;
    return managedObjectContext;
}

- (NSManagedObjectContext *)newChildMainQueueManagedObjectContext {
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    managedObjectContext.parentContext = self;
    return managedObjectContext;
}

- (NSManagedObjectContext *)newChildPrivateQueueManagedObjectContext {
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    managedObjectContext.parentContext = self;
    return managedObjectContext;
}

#pragma mark -

static NSString * const kReadOnlyFlagKey = @"isReadOnly";

- (void)setReadOnly:(BOOL)readOnly {
    objc_setAssociatedObject(self, (__bridge void *)(kReadOnlyFlagKey), @(readOnly), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)isReadOnly {
    return [objc_getAssociatedObject(self, (__bridge const void *)(kReadOnlyFlagKey)) boolValue];
}

- (NSString *)entityNameForManagedObjectClass:(Class)objectClass {
    return [[self entityDescriptionForManagedObjectClass:objectClass] name];
}

- (NSEntityDescription *)entityDescriptionForManagedObjectClass:(Class)objectClass {
    NSManagedObjectModel *model = nil;

    NSManagedObjectContext *context = self;
    while (context && context.persistentStoreCoordinator == nil) {
        context = context.parentContext;
    }

    model = context.persistentStoreCoordinator.managedObjectModel;
    return [model entityDescriptionForManagedObjectClass:objectClass];
}

#pragma mark -

- (BOOL)saveChanges:(NSError **)inout_error {
    NSAssert(self.isReadOnly == false, @"Try to save readonly context");

    NSError *error = nil;
    if ([self hasChanges] && ![self save:&error]) {
        LOG_ON_ERROR(error);
    }

    if (error && inout_error) *inout_error = error;
    return (error == nil);
}

@end
