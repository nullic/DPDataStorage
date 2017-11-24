//
//  NSManagedObject+DataStorage.h
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 11/11/11.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (DataStorage)

+ (instancetype _Nonnull)insertInContext:(NSManagedObjectContext * _Nonnull)context;
+ (void)deleteAllEntriesInContext:(NSManagedObjectContext * _Nonnull)context;
+ (NSUInteger)allEntriesCountInContext:(NSManagedObjectContext * _Nonnull)context;

+ (instancetype _Nullable)entryWithValue:(id<NSObject> _Nullable)value
                                  forKey:(NSString * _Nonnull)key
                               inContext:(NSManagedObjectContext * _Nonnull)context;
+ (instancetype _Nullable)entryWithValue:(id<NSObject> _Nullable)value
                                  forKey:(NSString * _Nonnull)key
                  includesPendingChanges:(BOOL)includesPendingChanges
                               inContext:(NSManagedObjectContext * _Nonnull)context;
+ (NSArray <__kindof NSManagedObject *>* _Nonnull)entriesWithValue:(id<NSObject> _Nullable)value
                                                            forKey:(NSString * _Nonnull)key
                                                         inContext:(NSManagedObjectContext * _Nonnull)context;
+ (instancetype _Nullable)anyEntryInContext:(NSManagedObjectContext * _Nonnull)context;

+ (NSArray <__kindof NSManagedObject *>* _Nonnull)allEntriesInContext:(NSManagedObjectContext * _Nonnull)context;
+ (NSArray <__kindof NSManagedObject *>* _Nonnull)allEntriesWithSortDescriptors:(NSArray<NSSortDescriptor *> * _Nullable)sortDescrptors
                                                                      inContext:(NSManagedObjectContext * _Nonnull)context;

+ (NSFetchRequest * _Nonnull)newFetchRequestInContext:(NSManagedObjectContext * _Nonnull)context;
+ (NSFetchedResultsController * _Nonnull)fetchedResultsController:(id<NSFetchedResultsControllerDelegate> _Nullable)delegate
                                                        predicate:(NSPredicate * _Nullable)predicate
                                                  sortDescriptors:(NSArray<NSSortDescriptor *> * _Nonnull)sortDescriptors
                                                        inContext:(NSManagedObjectContext * _Nonnull)context;

- (BOOL)validate:(NSError * _Nullable * _Nullable)error;

@end
