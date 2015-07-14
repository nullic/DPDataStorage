//
//  NSManagedObject+DataStorage.h
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 11/11/11.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (DataStorage)

+ (instancetype)insertInContext:(NSManagedObjectContext *)context;
+ (void)deleteAllEntriesInContext:(NSManagedObjectContext *)context;
+ (NSUInteger)allEntriesCountInContext:(NSManagedObjectContext *)context;

+ (instancetype)entryWithValue:(id<NSObject>)value forKey:(NSString *)key inContext:(NSManagedObjectContext *)context;
+ (instancetype)anyEntryInContext:(NSManagedObjectContext *)context;
+ (NSArray *)allEntriesInContext:(NSManagedObjectContext *)context;

+ (NSFetchRequest *)newFetchRequestInContext:(NSManagedObjectContext *)context;
+ (NSFetchedResultsController *)fetchedResultsController:(id<NSFetchedResultsControllerDelegate>)delegate
                                               predicate:(NSPredicate *)predicate
                                         sortDescriptors:(NSArray *)sortDescriptors
                                               inContext:(NSManagedObjectContext *)context;

- (BOOL)validate:(NSError **)error;

@end
