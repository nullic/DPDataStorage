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

DISPATCH_EXPORT dispatch_queue_t _dispatch_parser_q;
#define dispatch_get_parser_queue() (_dispatch_parser_q)

extern NSString * const DPDataStorageDefaultStorageDidChangeNotification;

extern NSString * const DPDataStorageFetchRequestTemplateDidChangeNotification;
extern NSString * const DPDataStorageNotificationNameKey;

#define DPMainThreadAssert() NSAssert([NSThread isMainThread], @"%s should be call in main thread only", __FUNCTION__)

#define LOG_ON_ERROR(error) {if (error) {NSLog(@"WARNING: %s, %@", __FUNCTION__, error);}}
#if DEBUG
    #define FAIL_ON_ERROR(error) {if (error) {NSLog(@"ERROR: %s, %@", __FUNCTION__, error); __builtin_trap();}}
#else
    #define FAIL_ON_ERROR(error) {if (error) {NSLog(@"ERROR: %s, %@", __FUNCTION__, error); abort();}}
#endif

@interface DPDataStorage : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectContext *mainContext;
@property (readonly, strong, nonatomic) NSURL *URL;
@property (readonly, strong, nonatomic) NSDictionary *classNameToEntityNameMap;

+ (NSURL *)defaultDatabaseURL;

+ (BOOL)setupDefaultStorageWithModelName:(NSString *)modelName storageURL:(NSURL *)storageURL;
+ (instancetype)defaultStorage;
+ (instancetype)storageWithModelURL:(NSURL *)modelURL storageURL:(NSURL *)storageURL;
- (void)makeDefault;

- (void)setFetchRequestTemplate:(NSFetchRequest *)fetchRequestTemplate forName:(NSString *)name;
- (void)setFetchRequestTemplateWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors forName:(NSString *)name;

- (NSManagedObjectContext *)newManagedObjectContext;
- (NSManagedObjectContext *)newMainQueueManagedObjectContext;
- (NSManagedObjectContext *)newPrivateQueueManagedObjectContext;
@end
