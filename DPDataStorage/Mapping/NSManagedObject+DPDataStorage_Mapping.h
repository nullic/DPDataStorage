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

+ (NSArray <__kindof NSManagedObject *>* _Nullable)updateWithArray:(NSArray * _Nonnull)array inContext:(NSManagedObjectContext * _Nonnull)context error:(NSError * _Nullable * _Nullable)out_error;
+ (instancetype _Nullable)updateWithDictionary:(NSDictionary * _Nonnull)dictionary inContext:(NSManagedObjectContext * _Nonnull)context error:(NSError * _Nullable * _Nullable)out_error;
- (BOOL)updateWithDictionary:(NSDictionary * _Nonnull)dictionary error:(NSError * _Nullable * _Nullable)out_error;
- (BOOL)updateAttributesWithDictionary:(NSDictionary * _Nonnull)dictionary error:(NSError * _Nullable * _Nullable)out_error;
- (BOOL)updateRelationshipsWithDictionary:(NSDictionary * _Nonnull)dictionary error:(NSError * _Nullable * _Nullable)out_error;
@end
