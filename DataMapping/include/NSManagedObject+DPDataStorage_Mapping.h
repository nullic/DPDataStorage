//
//  NSManagedObject+DPDataStorage_Mapping.h
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 06/05/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (DPDataStorage_Mapping)
+ (id _Nullable)transformImportValue:(id _Nonnull)value importKey:(NSString * _Nonnull)importKey propertyDescription:(NSPropertyDescription * _Nonnull)propertyDescription;

+ (NSArray <__kindof NSManagedObject *>* _Nullable)updateWithArray:(NSArray<NSDictionary<NSString *, id> *> * _Nonnull)array inContext:(NSManagedObjectContext * _Nonnull)context error:(NSError * _Nullable * _Nullable)out_error;
+ (instancetype _Nullable)updateWithDictionary:(NSDictionary<NSString *, id> * _Nonnull)dictionary inContext:(NSManagedObjectContext * _Nonnull)context error:(NSError * _Nullable * _Nullable)out_error;
- (BOOL)updateWithDictionary:(NSDictionary<NSString *, id> * _Nonnull)dictionary error:(NSError * _Nullable * _Nullable)out_error;
- (BOOL)updateAttributesWithDictionary:(NSDictionary<NSString *, id> * _Nonnull)dictionary error:(NSError * _Nullable * _Nullable)out_error;
- (BOOL)updateRelationshipsWithDictionary:(NSDictionary<NSString *, id> * _Nonnull)dictionary error:(NSError * _Nullable * _Nullable)out_error;

+ (id _Nullable)transformExportValue:(id _Nullable)value exportKey:(NSString * _Nonnull)importKey propertyDescription:(NSPropertyDescription * _Nonnull)propertyDescription;

+ (NSArray<NSString *> *_Nonnull)importKeysInContext:(NSManagedObjectContext * _Nonnull)context;

- (NSDictionary * _Nonnull)exportDictionary;
- (NSDictionary * _Nonnull)exportAttributesDictionary;
- (NSDictionary * _Nonnull)exportRelationshipsDictionary;

@end
