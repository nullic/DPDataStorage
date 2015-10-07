//
//  NSManagedObjectModel+DataStorage.m
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 29/04/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "NSManagedObjectModel+DataStorage.h"

@implementation NSManagedObjectModel (DataStorage)

- (NSString *)entityNameForManagedObjectClass:(Class)objectClass {
    return [[self entityDescriptionForManagedObjectClass:objectClass] name];
}

- (NSEntityDescription *)entityDescriptionForManagedObjectClass:(Class)objectClass {
    NSEntityDescription *result = nil;
    NSString *className = NSStringFromClass(objectClass);

    NSArray *entities = [self.entitiesByName allValues];
    for (NSEntityDescription *entityDescription in entities) {
        if ([entityDescription.managedObjectClassName isEqualToString:className]) {
            result = entityDescription;
            break;
        }
    }

    return result;
}

@end
