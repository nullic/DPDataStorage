//
//  NSManagedObject+DPDataStorage_Mapping.h
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 06/05/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (DPDataStorage_Mapping)
+ (id)transformImportValue:(id)value importKey:(NSString *)importKey propertyDescription:(NSPropertyDescription *)propertyDescription;

+ (NSArray *)updateWithArray:(NSArray *)array inContext:(NSManagedObjectContext *)context error:(NSError **)out_error;
+ (instancetype)updateWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context error:(NSError **)out_error;
- (BOOL)updateAttributesWithDictionary:(NSDictionary *)dictionary error:(NSError **)out_error;
- (BOOL)updateRelationshipsWithDictionary:(NSDictionary *)dictionary error:(NSError **)out_error;
@end
