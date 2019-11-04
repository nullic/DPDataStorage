//
//  NSManagedObjectContext+DataStorage.m
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 11/11/11.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "NSManagedObjectContext+DataStorage.h"
#import "NSManagedObjectModel+EntityDescription.h"
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

#pragma mark -

- (void)deleteObjects:(id<NSFastEnumeration>)objects {
    for (NSManagedObject *object in objects) {
        [self deleteObject:object];
    }
}

- (NSArray<__kindof NSManagedObject*> *)existingObjectsWithIds:(NSArray<NSManagedObjectID *> *)ids error:(NSError **)error {
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:ids.count];
    __block NSError *resultError = nil;
    [ids enumerateObjectsUsingBlock:^(NSManagedObjectID *objectID, NSUInteger idx, BOOL *stop) {
        NSManagedObject *managedObject = [self existingObjectWithID:objectID error:&resultError];
        if (resultError != nil) {
            *stop = YES;
        } else if (managedObject != nil) {
            [resultArray addObject:managedObject];
        }
    }];
    if (error) *error = resultError;
    return resultError == nil ? resultArray : nil;
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
