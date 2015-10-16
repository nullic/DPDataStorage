//
//  DPDataStorage.h
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 11/11/11.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "NSManagedObject+DataStorage.h"
#import "NSManagedObjectContext+DataStorage.h"
#import "NSManagedObjectModel+DataStorage.h"
#import "NSManagedObject+DPDataStorage_Mapping.h"

#import "DPCollectionViewDataSource.h"
#import "DPTableViewDataSource.h"
#import "DPArrayController.h"


DISPATCH_EXPORT dispatch_queue_t _Nonnull _dispatch_parser_q;
#define dispatch_get_parser_queue() (_dispatch_parser_q)

extern NSString * const _Nonnull DPDataStorageDefaultStorageDidChangeNotification;

extern NSString * const _Nonnull DPDataStorageFetchRequestTemplateDidChangeNotification;
extern NSString * const _Nonnull DPDataStorageNotificationNameKey;

#define DPMainThreadAssert() NSAssert([NSThread isMainThread], @"%s should be call in main thread only", __FUNCTION__)

#define LOG_ON_ERROR(error) {if (error) {NSLog(@"WARNING: %s, %@", __FUNCTION__, error);}}
#if DEBUG
    #define FAIL_ON_ERROR(error) {if (error) {NSLog(@"ERROR: %s, %@", __FUNCTION__, error); __builtin_trap();}}
#else
    #define FAIL_ON_ERROR(error) {if (error) {NSLog(@"ERROR: %s, %@", __FUNCTION__, error); abort();}}
#endif

@interface DPDataStorage : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectModel * _Nonnull managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator * _Nonnull persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectContext * _Nonnull mainContext;
@property (readonly, strong, nonatomic) NSURL * _Nullable URL;
@property (readonly, strong, nonatomic) NSDictionary * _Nonnull classNameToEntityNameMap;

/**
 @return URL for DataStorage.sqlite file in documents dir that can be used for creating storage.
*/
+ (NSURL * _Nonnull)storageDefaultURL;
+ (void)resetDefaultStorage;

+ (BOOL)setupDefaultStorageWithModelName:(NSString * _Nullable)modelName storageURL:(NSURL * _Nullable)storageURL;
+ (instancetype _Null_unspecified)defaultStorage;
+ (instancetype _Nullable)storageWithModelURL:(NSURL * _Nullable)modelURL storageURL:(NSURL * _Nullable)storageURL;
- (void)makeDefault;

- (void)setFetchRequestTemplate:(NSFetchRequest * _Nullable)fetchRequestTemplate forName:(NSString * _Null_unspecified)name;
- (void)setFetchRequestTemplateWithEntityName:(NSString * _Nonnull)entityName predicate:(NSPredicate * _Nullable)predicate sortDescriptors:(NSArray * _Nullable)sortDescriptors forName:(NSString * _Nonnull)name;

- (NSManagedObjectContext * _Nonnull)newManagedObjectContext NS_ENUM_DEPRECATED(10_4,10_11,3_0,9_0, "Use another NSManagedObjectContextConcurrencyType");
- (NSManagedObjectContext * _Nonnull)newMainQueueManagedObjectContext;
- (NSManagedObjectContext * _Nonnull)newPrivateQueueManagedObjectContext;
@end
