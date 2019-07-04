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
#import "NSManagedObjectModel+EntityDescription.h"
#import "NSManagedObject+DPDataStorage_Mapping.h"

#import "DPCollectionViewDataSource.h"
#import "DPTableViewDataSource.h"
#import "DPMapViewDataSource.h"
#import "DPArrayController.h"
#import "DPFilteredArrayController.h"
#import "DPSectionedArrayController.h"
#import "DPSectionedFetchedResultsController.h"
#import "DPContainerControllerBasedController.h"


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
@property (readonly, strong, nonatomic) NSManagedObjectContext * _Nonnull parseContext;
@property (readonly, strong, nonatomic) NSURL * _Nullable URL;
@property (readonly, strong, nonatomic) NSDictionary * _Nonnull classNameToEntityNameMap;
@property (readonly, copy, nonatomic) NSString * _Nullable defaultStoreConfiguration;

/*!
 @discussion Before using should be setup with  + [self setupDefaultStorageWithModelName:storageURL:] or - [self makeDefault].
 @return Default DPDataSotrage object associated with application.
 */
+ (instancetype _Null_unspecified)defaultStorage;

/**
 @method
 @param modelName Use to set name for model that should be loaded for default storage. 
  If passed `nil` model whould be created with 'mergedModelFromBundles:nil' that  merge all models from main bundle.
 @param storageURL Use to set URL for storage file. You can use `storageDefaultURL` here for default path.
  If passed `nil` persistent store whould be created with type `NSInMemoryStoreType`.
 @return YES if setup was successed, NO otherwise.
 */
+ (BOOL)setupDefaultStorageWithModelName:(NSString * _Nullable)modelName storageURL:(NSURL * _Nullable)storageURL;

/**
 @return URL for DataStorage.sqlite file in documents directory that can be used for creating storage.
 */
+ (NSURL * _Nonnull)storageDefaultURL;

/**
 @method
 @discussion Use to set current `DPDataStorage` object as default.
 */
- (void)makeDefault;

/**
 @method
 @discussion Use to set current default `DPDataStorage` object to nil .
 */
+ (void)resetDefaultStorage;

/**
 @method
 @param modelURL Use to set URL for model that should be loaded for default storage.
  If passed `nil` model whould be created with 'mergedModelFromBundles:nil' that  merge all models from main bundle.
 @param storageURL Use to set URL for storage file. You can use `storageDefaultURL` here for default path.
  If passed `nil` persistent store whould be created with type `NSInMemoryStoreType`.
 @param allowStoreDropOnError Use to allow remove store from disk if model can not be added to coordinator
  By defaut equal to YES if DEBUG defined, else equal to NO.
 @return Initialized DPDataStorage object with provided info.
 */
+ (instancetype _Nullable)storageWithModelURL:(NSURL * _Nonnull)modelURL storageURL:(NSURL * _Nullable)storageURL allowStoreDropOnError:(BOOL)allowStoreDropOnError defaultStoreConfiguration:(NSString * _Nullable)defaultStoreConfiguration;
+ (instancetype _Nullable)storageWithModelURL:(NSURL * _Nonnull)modelURL storageURL:(NSURL * _Nullable)storageURL;

+ (instancetype _Nullable)storageWithMergedModelFromBundles:(NSArray<NSBundle *> * _Nullable)bundles storageURL:(NSURL * _Nullable)storageURL allowStoreDropOnError:(BOOL)allowStoreDropOnError defaultStoreConfiguration:(NSString * _Nullable)defaultStoreConfiguration;
+ (instancetype _Nullable)storageWithMergedModelFromBundles:(NSArray<NSBundle *> * _Nullable)bundles storageURL:(NSURL * _Nullable)storageURL;

/**
 @method
 @return Initialized NSManagedObjectContext with `NSMainQueueConcurrencyType` concurrency type.
 */
- (NSManagedObjectContext * _Nonnull)newMainQueueManagedObjectContext;

/**
 @method
 @return Initialized NSManagedObjectContext with `NSPrivateQueueConcurrencyType` concurrency type.
 */
- (NSManagedObjectContext * _Nonnull)newPrivateQueueManagedObjectContext;

/**
 @method
 @return Initialized NSManagedObjectContext with `NSConfinementConcurrencyType` concurrency type.
 */
- (NSManagedObjectContext * _Nonnull)newManagedObjectContext NS_ENUM_DEPRECATED(10_4,10_11,3_0,9_0, "Use another NSManagedObjectContextConcurrencyType");

- (void)setFetchRequestTemplate:(NSFetchRequest * _Nullable)fetchRequestTemplate forName:(NSString * _Null_unspecified)name;
- (void)setFetchRequestTemplateWithEntityName:(NSString * _Nonnull)entityName predicate:(NSPredicate * _Nullable)predicate sortDescriptors:(NSArray * _Nullable)sortDescriptors forName:(NSString * _Nonnull)name;


- (void)resetAllData;
- (BOOL)resetAllDataUsingContext:(NSManagedObjectContext * _Nonnull)context error:(NSError * _Nullable * _Nullable)error;

@end
