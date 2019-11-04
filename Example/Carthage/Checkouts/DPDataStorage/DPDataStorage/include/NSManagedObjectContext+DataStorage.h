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
@property (nonatomic) BOOL deleteInvalidObjectsOnSave;

+ (NSManagedObjectContext * _Null_unspecified)mainContext;
+ (NSManagedObjectContext * _Null_unspecified)parseContext;
+ (NSManagedObjectContext * _Null_unspecified)newManagedObjectContext NS_ENUM_DEPRECATED(10_4,10_11,3_0,9_0, "Use another NSManagedObjectContextConcurrencyType");
+ (NSManagedObjectContext * _Null_unspecified)newMainQueueManagedObjectContext;
+ (NSManagedObjectContext * _Null_unspecified)newPrivateQueueManagedObjectContext;

- (NSManagedObjectContext * _Null_unspecified)newChildManagedObjectContext NS_ENUM_DEPRECATED(10_4,10_11,3_0,9_0, "Use another NSManagedObjectContextConcurrencyType");
- (NSManagedObjectContext * _Null_unspecified)newChildMainQueueManagedObjectContext;
- (NSManagedObjectContext * _Null_unspecified)newChildPrivateQueueManagedObjectContext;

- (void)deleteObjects:(id<NSFastEnumeration> _Nullable)objects; // expects a collection of NSManagedObjects
- (NSArray<__kindof NSManagedObject *> * _Null_unspecified)existingObjectsWithIds:(NSArray<NSManagedObjectID *> * _Nonnull)ids error:(NSError * _Nullable * _Nullable)error;

- (BOOL)saveChanges:(NSError * _Nullable * _Nullable)error;
@end
