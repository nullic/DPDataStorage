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

+ (NSManagedObjectContext *)parseContext {
    return [[DPDataStorage defaultStorage] parseContext];
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
static NSString * const kDeleteInvalidObjectsFlagKey = @"deleteInvalidObjects";
static NSString * const kParseDataHasDuplicatesKey = @"parseDataHasDuplicates";


- (void)setReadOnly:(BOOL)readOnly {
    objc_setAssociatedObject(self, (__bridge void *)(kReadOnlyFlagKey), @(readOnly), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)isReadOnly {
    return [objc_getAssociatedObject(self, (__bridge const void *)(kReadOnlyFlagKey)) boolValue];
}

- (void)setDeleteInvalidObjectsOnSave:(BOOL)deleteInvalidObjectsOnSave {
    objc_setAssociatedObject(self, (__bridge void *)(kDeleteInvalidObjectsFlagKey), @(deleteInvalidObjectsOnSave), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)deleteInvalidObjectsOnSave {
    return [objc_getAssociatedObject(self, (__bridge const void *)(kDeleteInvalidObjectsFlagKey)) boolValue];
}

- (void)setParseDataHasDuplicates:(BOOL)parseDataHasDuplicates {
    objc_setAssociatedObject(self, (__bridge void *)(kParseDataHasDuplicatesKey), @(parseDataHasDuplicates), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)parseDataHasDuplicates {
    return [(objc_getAssociatedObject(self, (__bridge const void *)(kParseDataHasDuplicatesKey)) ?: @YES) boolValue];
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

- (void)deleteObjects:(id<NSFastEnumeration>)objects {
    for (NSManagedObject *object in objects) {
        [self deleteObject:object];
    }
}

#pragma mark -

- (BOOL)saveChanges:(NSError **)inout_error {
    NSAssert(self.isReadOnly == false, @"Try to save readonly context");

    NSError *error = nil;
    if ([self hasChanges]) {
        while (YES) {
            [self save:&error];
            
            if (error && self.deleteInvalidObjectsOnSave && [self deleteInvalidObjectsFromError:error] == NO) {
                error = nil;
                continue;
            }
            
            break;
        }

        LOG_ON_ERROR(error);
    }

    if (error && inout_error) *inout_error = error;
    return (error == nil);
}

- (BOOL)deleteInvalidObjectsFromError:(NSError *)error {
    BOOL result = YES;
    
    NSArray *errors = @[error];
    if (error.code == NSValidationMultipleErrorsError) {
        errors = error.userInfo[NSDetailedErrorsKey];
    }

    for (NSError *e in errors) {
        switch (e.code) {
            case NSManagedObjectValidationError:
            case NSManagedObjectConstraintValidationError:
            case NSValidationMissingMandatoryPropertyError:
            case NSValidationRelationshipLacksMinimumCountError:
            case NSValidationRelationshipExceedsMaximumCountError:
            case NSValidationRelationshipDeniedDeleteError:
            case NSValidationNumberTooLargeError:
            case NSValidationNumberTooSmallError:
            case NSValidationDateTooLateError:
            case NSValidationDateTooSoonError:
            case NSValidationInvalidDateError:
            case NSValidationStringTooLongError:
            case NSValidationStringTooShortError:
            case NSValidationStringPatternMatchingError:
            case NSValidationInvalidURIError:
            {
                NSManagedObject *obj = e.userInfo[NSValidationObjectErrorKey];
                if (obj && obj.isDeleted == NO) {
                    [self deleteObject:obj];
                    result = NO;
                }
                break;
            }
            default: break;
        }
    }
    
    return result;
}

@end
