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
@property (nonatomic) BOOL parseDataHasDuplicates;

+ (NSManagedObjectContext * _Null_unspecified)mainContext;
+ (NSManagedObjectContext * _Null_unspecified)parseContext;
+ (NSManagedObjectContext * _Null_unspecified)newManagedObjectContext NS_ENUM_DEPRECATED(10_4,10_11,3_0,9_0, "Use another NSManagedObjectContextConcurrencyType");
+ (NSManagedObjectContext * _Null_unspecified)newMainQueueManagedObjectContext;
+ (NSManagedObjectContext * _Null_unspecified)newPrivateQueueManagedObjectContext;

- (NSManagedObjectContext * _Null_unspecified)newChildManagedObjectContext NS_ENUM_DEPRECATED(10_4,10_11,3_0,9_0, "Use another NSManagedObjectContextConcurrencyType");
- (NSManagedObjectContext * _Null_unspecified)newChildMainQueueManagedObjectContext;
- (NSManagedObjectContext * _Null_unspecified)newChildPrivateQueueManagedObjectContext;

- (NSString * _Nonnull)entityNameForManagedObjectClass:(Class _Nonnull)objectClass;
- (NSEntityDescription * _Nonnull)entityDescriptionForManagedObjectClass:(Class _Nonnull)objectClass;

- (void)deleteObjects:(id<NSFastEnumeration> _Nullable)objects; // expects a collection of NSManagedObjects
- (BOOL)saveChanges:(NSError * _Nullable * _Nullable)error;
@end
