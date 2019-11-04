//
//  NSManagedObjectContext.m
//  DPDataStorage
//
//  Created by Alexey Bakhtin on 12/22/18.
//  Copyright © 2018 Dmitriy Petrusevich. All rights reserved.
//

#import "NSManagedObjectContext+EntityDescription.h"
#import "NSManagedObjectModel+EntityDescription.h"

@implementation NSManagedObjectContext (EntityDescription)

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

@end
