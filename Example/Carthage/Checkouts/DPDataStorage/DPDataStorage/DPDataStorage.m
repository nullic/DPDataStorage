//
//  DPDataStorage.m
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 11/11/11.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "DPDataStorage.h"
#import <objc/runtime.h>


#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif


@interface __DPDS_OnDeallocContainer__ : NSObject
@property (nonatomic, copy) void(^block)(void);
@end

@implementation __DPDS_OnDeallocContainer__

- (id)initWithBlock:(void(^)(void))block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

- (void)dealloc {
    if (self.block) {
        self.block();
    }
}

@end

@interface NSObject (DPCommons)
@end

@implementation NSObject (DPCommons)
- (void)__executeOnDealloc__:(void(^)(void))onDeallocBlock {
    if (onDeallocBlock) {
        __DPDS_OnDeallocContainer__ *action = [[__DPDS_OnDeallocContainer__ alloc] initWithBlock:onDeallocBlock];
        objc_setAssociatedObject(self, (__bridge void *)(action), action, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
@end


#pragma mark -


dispatch_queue_t _dispatch_parser_q = NULL;
static DPDataStorage *_sharedInstance = nil;

NSString * const DPDataStorageDefaultStorageDidChangeNotification = @"DPDataStorageDefaultStorageDidChangeNotification";
NSString * const DPDataStorageFetchRequestTemplateDidChangeNotification = @"DPDataStorageFetchRequestTemplateDidChangeNotification";
NSString * const DPDataStorageNotificationNameKey = @"name";


@interface DPDataStorage()
@property (readwrite, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readwrite, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readwrite, strong, nonatomic) NSManagedObjectContext *mainContext;
@property (readwrite, strong, nonatomic) NSManagedObjectContext *parseContext;
@property (readwrite, strong, nonatomic) NSURL *URL;
@property (readwrite, strong, nonatomic) NSDictionary *classNameToEntityNameMap;
@property (readwrite, copy, nonatomic) NSString *defaultStoreConfiguration;
@property (readwrite, assign, nonatomic) BOOL allowStoreDropOnError;

@end

@implementation DPDataStorage

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ {URL = '%@'}", [super description], self.URL];
}

#pragma mark -

+ (void)load {
    @autoreleasepool {
        _dispatch_parser_q = dispatch_queue_create("ind.dmitriy-petrusevich.datastorage.parser", NULL);
    }
}

+ (NSURL *)storageDefaultURL {
    NSString *bundleID = [[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"] lowercaseString];
    NSString *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    path = [path stringByAppendingPathComponent:bundleID];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        LOG_ON_ERROR(error);
    }

    return [NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"DataStorage.sqlite"] isDirectory:NO];
}

+ (BOOL)setupDefaultStorageWithModelName:(NSString *)modelName storageURL:(NSURL *)storageURL {
    [self resetDefaultStorage];

    NSURL *modelURL = modelName ? ([[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"] ?: [[NSBundle mainBundle] URLForResource:modelName withExtension:@"mom"]) : nil;

    if (modelName && modelURL) {
        [[self storageWithModelURL:modelURL storageURL:storageURL] makeDefault];
    }
    else if (modelName == nil) {
        [[self storageWithMergedModelFromBundles:nil storageURL:storageURL] makeDefault];
    }

    return ([self defaultStorage] != nil);
}

+ (instancetype)defaultStorage {
    @synchronized(self) {
        return _sharedInstance;
    }
}

+ (void)resetDefaultStorage {
    @synchronized(self) {
        _sharedInstance = nil;
    }
}

+ (instancetype)storageWithModelURL:(NSURL *)modelURL storageURL:(NSURL *)storageURL {
    BOOL allowStoreDropOnError = NO;
#if DEBUG
    allowStoreDropOnError = YES;
#endif
    return [self storageWithModelURL:modelURL storageURL:storageURL allowStoreDropOnError:allowStoreDropOnError defaultStoreConfiguration: nil];
}

+ (instancetype)storageWithModelURL:(NSURL *)modelURL storageURL:(NSURL *)storageURL allowStoreDropOnError:(BOOL)allowStoreDropOnError defaultStoreConfiguration:(NSString * _Nullable)defaultStoreConfiguration {
    DPDataStorage *storage = [[self alloc] init];
    storage.defaultStoreConfiguration = defaultStoreConfiguration;
    storage.allowStoreDropOnError = allowStoreDropOnError;
    storage.URL = storageURL;
    storage.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return storage.managedObjectModel ? storage : nil;
}

+ (instancetype)storageWithMergedModelFromBundles:(NSArray<NSBundle *> * _Nullable)bundles storageURL:(NSURL *)storageURL {
    BOOL allowStoreDropOnError = NO;
#if DEBUG
    allowStoreDropOnError = YES;
#endif
    return [self storageWithMergedModelFromBundles:bundles storageURL:storageURL allowStoreDropOnError:allowStoreDropOnError defaultStoreConfiguration: nil];
}

+ (instancetype)storageWithMergedModelFromBundles:(nullable NSArray<NSBundle *> *)bundles storageURL:(NSURL *)storageURL allowStoreDropOnError:(BOOL)allowStoreDropOnError defaultStoreConfiguration:(NSString * _Nullable)defaultStoreConfiguration {
    DPDataStorage *storage = [[self alloc] init];
    storage.defaultStoreConfiguration = defaultStoreConfiguration;
    storage.allowStoreDropOnError = allowStoreDropOnError;
    storage.URL = storageURL;
    storage.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:bundles];
    return storage.managedObjectModel ? storage : nil;
}

- (void)makeDefault {
    @synchronized(self) {
        _sharedInstance = self;
    }

    dispatch_block_t action = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DPDataStorageDefaultStorageDidChangeNotification object:nil];
    };
    [NSThread isMainThread] ? action() : dispatch_async(dispatch_get_main_queue(), action);
}

#pragma mark -

- (void)setFetchRequestTemplate:(NSFetchRequest *)fetchRequestTemplate forName:(NSString *)name {
    if (name) {
        [self.managedObjectModel setFetchRequestTemplate:fetchRequestTemplate forName:name];
        dispatch_block_t action = ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:DPDataStorageFetchRequestTemplateDidChangeNotification object:self userInfo:@{DPDataStorageNotificationNameKey:name}];
        };
        [NSThread isMainThread] ? action() : dispatch_async(dispatch_get_main_queue(), action);
    }
}

- (void)setFetchRequestTemplateWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors forName:(NSString *)name {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = self.managedObjectModel.entitiesByName[entityName];
    fetchRequest.sortDescriptors = sortDescriptors;
    fetchRequest.predicate = predicate;
    [self setFetchRequestTemplate:fetchRequest forName:name];
}

#pragma mark - Core Data stack

- (void)setManagedObjectModel:(NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != managedObjectModel) {

        NSArray *entities = [managedObjectModel.entitiesByName allValues];
        NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:entities.count];
        for (NSEntityDescription *entityDescription in entities) {
            [map setValue:entityDescription.name forKey:entityDescription.managedObjectClassName];
        }

        self.classNameToEntityNameMap = map;
        _managedObjectModel = managedObjectModel;
    }
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    @synchronized(self) {
        if (!_persistentStoreCoordinator) {
            if (self.URL) {
                NSString *folder = [[self.URL URLByDeletingLastPathComponent] path];
                [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:true attributes:nil error:nil];

                NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};

                NSError *error = nil;
                _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
                if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:self.defaultStoreConfiguration URL:self.URL options:options error:&error]) {
                    if (self.allowStoreDropOnError) {
                        LOG_ON_ERROR(error); error = nil;
                        [[NSFileManager defaultManager] removeItemAtURL:self.URL error:&error];
                        FAIL_ON_ERROR(error);
                        
                        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:self.defaultStoreConfiguration URL:self.URL options:options error:&error]) {
                            FAIL_ON_ERROR(error);
                        }
                    } else {
                        FAIL_ON_ERROR(error);
                    }
                }
            }
            else {
                NSError *error = nil;
                _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
                if (![_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:self.defaultStoreConfiguration URL:nil options:nil error:&error]) {
                    FAIL_ON_ERROR(error);
                }
            }
        }
        
        return _persistentStoreCoordinator;
    }
}

- (NSManagedObjectContext *)mainContext {
    @synchronized(self) {
        if (!_mainContext) {
            _mainContext = [self newMainQueueManagedObjectContext];
            _mainContext.readOnly = YES;
            
            id __weak weakContext = _mainContext;
            id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
                NSManagedObjectContext *context = weakContext;
                if ([context persistentStoreCoordinator] == [notification.object persistentStoreCoordinator] && ([notification.object parentContext] == nil || [notification.object parentContext] == context)) {
                    [context performBlock:^{
                        [context mergeChangesFromContextDidSaveNotification:notification];
                    }];
                }
            }];
            
            [_mainContext __executeOnDealloc__:^{
                [[NSNotificationCenter defaultCenter] removeObserver:observer];
            }];
        }

        return _mainContext;
    }
}

- (NSManagedObjectContext *)parseContext {
    @synchronized(self) {
        if (!_parseContext) {
            _parseContext = [self newPrivateQueueManagedObjectContext];

            id __weak weakContext = _parseContext;
            id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
                NSManagedObjectContext *context = weakContext;
                if ([context persistentStoreCoordinator] == [notification.object persistentStoreCoordinator] && ([notification.object parentContext] == nil || [notification.object parentContext] == context)) {
                    [context performBlock:^{
                        [context mergeChangesFromContextDidSaveNotification:notification];
                    }];
                }
            }];

            [_parseContext __executeOnDealloc__:^{
                [[NSNotificationCenter defaultCenter] removeObserver:observer];
            }];
        }

        return _parseContext;
    }
}


#pragma mark - Context

- (NSManagedObjectContext*)newManagedObjectContext {
    NSManagedObjectContext *managedObjectContext = nil;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}

- (NSManagedObjectContext*)newMainQueueManagedObjectContext {
    NSManagedObjectContext *managedObjectContext = nil;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}

- (NSManagedObjectContext*)newPrivateQueueManagedObjectContext {
    NSManagedObjectContext *managedObjectContext = nil;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}

#pragma mark -

- (void)resetAllData {
    [self resetAllDataUsingContext:[self newPrivateQueueManagedObjectContext] error:NULL];
}

- (BOOL)resetAllDataUsingContext:(NSManagedObjectContext *)context error:(NSError **)out_error {
    __block NSError *error = nil;
    [context performBlockAndWait:^{
        for (NSEntityDescription *entry in context.persistentStoreCoordinator.managedObjectModel.entities) {
            @autoreleasepool {
                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entry.name];
                NSArray *allentries = [context executeFetchRequest:request error:&error];
                for (NSManagedObject *obj in allentries) {
                    [context deleteObject:obj];
                }
            }

            if (error) return;
        }
        [context save:&error];
    }];

    if (error && out_error) *out_error = error;
    return (error == nil) ? true : false;
}

@end
