//
//  NSManagedObjectContext+DataStorage.h
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 11/11/11.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (DataStorage)
@property (nonatomic, getter=isReadOnly) BOOL readOnly;

+ (NSManagedObjectContext *)mainContext;
+ (NSManagedObjectContext *)newManagedObjectContext;
+ (NSManagedObjectContext *)newMainQueueManagedObjectContext;
+ (NSManagedObjectContext *)newPrivateQueueManagedObjectContext;

- (NSManagedObjectContext *)newChildManagedObjectContext;
- (NSManagedObjectContext *)newChildMainQueueManagedObjectContext;
- (NSManagedObjectContext *)newChildPrivateQueueManagedObjectContext;

- (NSString *)entityNameForManagedObjectClass:(Class)objectClass;
- (NSEntityDescription *)entityDescriptionForManagedObjectClass:(Class)objectClass;

- (BOOL)saveChanges:(NSError **)error;
@end
