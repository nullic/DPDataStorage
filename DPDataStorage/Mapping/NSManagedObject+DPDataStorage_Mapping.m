//
//  NSManagedObject+DPDataStorage_Mapping.m
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 06/05/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "NSManagedObject+DPDataStorage_Mapping.h"
#import "NSManagedObject+DataStorage.h"
#import "DPDataStorage.h"


static NSString * const kUniqueKey = @"uniqueKey";
static NSString * const kImportKey = @"importKey";
static NSString * const kExportKey = @"exportKey";
static NSString * const kDeleteOnReplaceKey = @"deleteOnReplace";
static NSString * const kDeleteNotUpdatedKey = @"deleteNotUpdated";
static NSString * const kParseDataHasDuplicatesKey = @"parseDuplicates";


static NSString * uniqueKeyForEntity(NSEntityDescription *entityDescription) {
    NSString *entityUniqueKey = nil;
    NSEntityDescription *parent = entityDescription;
    while (parent != nil && entityUniqueKey == nil) {
        entityUniqueKey = parent.userInfo[kUniqueKey];
        parent = parent.superentity;
    }
    return entityUniqueKey;
}

@interface NSEntityDescription (DPDataStorage_Mapping)
@end

@implementation NSEntityDescription (DPDataStorage_Mapping)

- (NSArray<NSString *> *)importKeysForAttributeKeys:(NSArray<NSString *> *)keys inDictionary:(NSDictionary *)dictionary error:(NSError **)out_error {
    NSError *error = nil;
    NSMutableArray *result = [NSMutableArray array];
    
    for (NSString *key in keys) {
        NSAttributeDescription *attr = self.attributesByName[key];
        
        for (NSString *key in attr.userInfo) {
            if ([key hasPrefix:kImportKey]) {
                NSString *importKey = attr.userInfo[key];
                
                if (dictionary[importKey] != nil) {
                    [result addObject:importKey];
                    break;
                }
            }
        }
    }
    
    if (result.count != keys.count) {
        NSString *details = [NSString stringWithFormat:@"Not found '%@' for '%@' in class: %@", kImportKey, kUniqueKey, NSStringFromClass([self class])];
        error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSExternalRecordImportError userInfo:@{NSLocalizedFailureReasonErrorKey: details}];
    }
    
    if (error && out_error) *out_error = error;
    return (error == nil) ? result : nil;
}

@end


@implementation NSManagedObject (DPDataStorage_Mapping)

#pragma mark - Import

+ (NSArray<NSString *> *)importKeysInContext:(NSManagedObjectContext *)context {
    NSMutableArray *importKeys = [NSMutableArray array];
    NSEntityDescription *entityDescription = [context entityDescriptionForManagedObjectClass:[self class]];
    NSDictionary *entityAttributes = entityDescription.attributesByName;

    for (NSString *attributeName in entityAttributes) {
        NSAttributeDescription *attributeDescription = entityAttributes[attributeName];
        for (NSString *key in attributeDescription.userInfo) {
            if ([key hasPrefix:kImportKey]) {
                [importKeys addObject:attributeDescription.userInfo[key]];
            }
        }
    }

    NSDictionary *entityRelationships = entityDescription.relationshipsByName;
    for (NSString *relationshipName in entityRelationships) {
        NSRelationshipDescription *relationshipDescription = entityRelationships[relationshipName];
        for (NSString *key in relationshipDescription.userInfo) {
            if ([key hasPrefix:kImportKey]) {
                [importKeys addObject:relationshipDescription.userInfo[key]];
            }
        }
    }
    return importKeys;
}

+ (id)transformImportValue:(id)value importKey:(NSString *)importKey propertyDescription:(NSPropertyDescription *)propertyDescription {
    return value;
}

+ (NSArray *)updateWithArray:(NSArray *)array inContext:(NSManagedObjectContext *)context error:(NSError **)out_error {
    NSError *error = nil;
    NSMutableArray *result = nil;

    if ([array isKindOfClass:[NSArray class]] == NO) {
        NSString *details = [NSString stringWithFormat:@"Invalid root import object (expected: %@, actual: %@) for class: %@", NSStringFromClass([NSArray class]), NSStringFromClass([array class]), NSStringFromClass([self class])];
        error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSExternalRecordImportError userInfo:@{NSLocalizedFailureReasonErrorKey: details}];
    }
    else {
        result = [NSMutableArray arrayWithCapacity:array.count];

        NSEntityDescription *entityDescription = [context entityDescriptionForManagedObjectClass:[self class]];
        NSDictionary *entityAttributes = [entityDescription attributesByName];
        
        NSString *entityUniqueKey = uniqueKeyForEntity(entityDescription);
        NSAttributeDescription *uniqueAttr = entityUniqueKey ? entityAttributes[entityUniqueKey] : nil;
        BOOL parseDataHasDuplicates = entityDescription.userInfo[kParseDataHasDuplicatesKey] ? [entityDescription.userInfo[kParseDataHasDuplicatesKey] boolValue] : context.parseDataHasDuplicates;

        NSString *importUniqueKey = nil;
        for (NSString *key in uniqueAttr.userInfo) {
            if ([key hasPrefix:kImportKey]) {
                NSDictionary *dictionary = [array.firstObject isKindOfClass:[NSDictionary class]] ? array.firstObject : nil;
                importUniqueKey = uniqueAttr.userInfo[key];
                if (dictionary[importUniqueKey] != nil) {
                    break;
                }
            }
        }
        Class uniqueValueClass = uniqueAttr ? NSClassFromString(uniqueAttr.attributeValueClassName) : nil;

        if (importUniqueKey != nil || entityUniqueKey == nil) {
            for (NSDictionary *itemInfo in array) {
                if ([itemInfo isKindOfClass:[NSDictionary class]] == NO) {
                    NSString *details = [NSString stringWithFormat:@"Invalid import object (expected: %@, actual: %@) for class: %@", NSStringFromClass([NSDictionary class]), NSStringFromClass([itemInfo class]), NSStringFromClass([self class])];
                    error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSExternalRecordImportError userInfo:@{NSLocalizedFailureReasonErrorKey: details}];
                }
                else {
                    if (entityUniqueKey == nil) {
                        [result addObject:[NSNull null]];
                    }
                    else {
                        id value = [self transformImportValue:itemInfo[importUniqueKey] importKey:importUniqueKey propertyDescription:uniqueAttr];
                        if (value) {
                            if ([value isKindOfClass:uniqueValueClass]) {
                                NSManagedObject *existObject = [self entryWithValue:value forKey:entityUniqueKey includesPendingChanges:parseDataHasDuplicates inContext:context];
                                [result addObject:existObject ? existObject : [NSNull null]];
                            }
                            else {
                                NSString *details = [NSString stringWithFormat:@"Invalid import value class (expected: %@, actual: %@) for key: '%@' in object: '%@'", uniqueAttr.attributeValueClassName, NSStringFromClass([value class]), entityUniqueKey, NSStringFromClass([self class])];
                                error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSExternalRecordImportError userInfo:@{NSLocalizedFailureReasonErrorKey: details}];
                            }
                        }
                        else {
                            NSString *details = [NSString stringWithFormat:@"Import value for unique key cannot be 'nil' (class: %@)", NSStringFromClass([self class])];
                            error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSExternalRecordImportError userInfo:@{NSLocalizedFailureReasonErrorKey: details}];
                        }
                    }
                }
            }
        }
        else {
            NSString *details = [NSString stringWithFormat:@"Not found '%@' for '%@' in class: %@", kImportKey, kUniqueKey, NSStringFromClass([self class])];
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSExternalRecordImportError userInfo:@{NSLocalizedFailureReasonErrorKey: details}];
        }

        if (error == nil) {
            NSAssert(result.count == array.count, @"Invalid result array length");

            for (NSInteger i = 0; i < array.count; i++) {
                if (result[i] == [NSNull null]) {
                    [result replaceObjectAtIndex:i withObject:[self insertInContext:context]];
                }

                NSDictionary *itemInfo = array[i];
                NSManagedObject *object = result[i];
                if (![object updateWithDictionary:itemInfo error:&error]) {
                    break;
                }
            }
        }
    }

    if (error && out_error) *out_error = error;
    return (error == nil) ? result : nil;
}

+ (BOOL)_classHasCustomUpdateWithDictionaryMethod {
    IMP classImpl = [self methodForSelector:@selector(updateWithDictionary:inContext:error:)];
    IMP baseImpl = [NSManagedObject methodForSelector:@selector(updateWithDictionary:inContext:error:)];
    return classImpl != baseImpl;
}

+ (instancetype)updateChildObjectWithDictionary:(NSDictionary *)dictionary parent:(NSManagedObject *)parent inContext:(NSManagedObjectContext *)context error:(NSError **)out_error {
    if ([self _classHasCustomUpdateWithDictionaryMethod]) {
        return [self updateWithDictionary:dictionary inContext:context error:out_error];
    }
    else {
        return [self _updateChildObjectWithDictionary:dictionary parent:parent inContext:context error:out_error];
    }
}

+ (instancetype)updateWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context error:(NSError **)out_error {
    return [self _updateChildObjectWithDictionary:dictionary parent:nil inContext:context error:out_error];
}

+ (instancetype)_updateChildObjectWithDictionary:(NSDictionary *)dictionary parent:(NSManagedObject *)parent inContext:(NSManagedObjectContext *)context error:(NSError **)out_error {
    NSError *error = nil;
    NSManagedObject *result = nil;

    if ([dictionary isKindOfClass:[NSDictionary class]] == NO) {
        NSString *details = [NSString stringWithFormat:@"Invalid root import object (expected: %@, actual: %@) for class: %@", NSStringFromClass([NSDictionary class]), NSStringFromClass([dictionary class]), NSStringFromClass([self class])];
        error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSExternalRecordImportError userInfo:@{NSLocalizedFailureReasonErrorKey: details}];
    }
    else {
        NSEntityDescription *entityDescription = [context entityDescriptionForManagedObjectClass:[self class]];
        NSDictionary *entityAttributes = [entityDescription attributesByName];

        NSString *entityUniqueKey = uniqueKeyForEntity(entityDescription);
        NSArray *uniqueKeys = [entityUniqueKey componentsSeparatedByString:@"+"];
        NSArray *importUniqueKeys = [entityDescription importKeysForAttributeKeys:uniqueKeys inDictionary:dictionary error:&error];
        
        BOOL parseDataHasDuplicates = entityDescription.userInfo[kParseDataHasDuplicatesKey] ? [entityDescription.userInfo[kParseDataHasDuplicatesKey] boolValue] : context.parseDataHasDuplicates;

        if (entityUniqueKey == nil || (parseDataHasDuplicates == false && parent.isInserted == true)) {
            result = [self insertInContext:context];
        }
        else if (error == nil && importUniqueKeys.count > 0 && importUniqueKeys.count == uniqueKeys.count) {
            NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
            
            for (NSInteger i = 0; i < importUniqueKeys.count; i++) {
                NSString *uniqueAttributeKey = uniqueKeys[i];
                NSAttributeDescription *uniqueAttr = entityAttributes[uniqueAttributeKey];
                NSString *importUniqueKey = importUniqueKeys[i];
                
                Class valueClass = NSClassFromString(uniqueAttr.attributeValueClassName);
                id value = [self transformImportValue:dictionary[importUniqueKey] importKey:importUniqueKey propertyDescription:uniqueAttr];
                
                if (value) {
                    if ([value isKindOfClass:valueClass]) {
                        pairs[uniqueAttributeKey] = value;
                    }
                    else {
                        NSString *details = [NSString stringWithFormat:@"Invalid import value class (expected: %@, actual: %@) for key: '%@' in object: '%@'", uniqueAttr.attributeValueClassName, NSStringFromClass([value class]), uniqueAttributeKey, NSStringFromClass([self class])];
                        error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSExternalRecordImportError userInfo:@{NSLocalizedFailureReasonErrorKey: details}];
                    }
                }
                else {
                    NSString *details = [NSString stringWithFormat:@"Import value for unique key cannot be 'nil' (class: %@)", NSStringFromClass([self class])];
                    error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSExternalRecordImportError userInfo:@{NSLocalizedFailureReasonErrorKey: details}];
                    break;
                }
            }
            
            if (error == nil) {
                result = [self entryWithPairs:pairs includesPendingChanges:parseDataHasDuplicates inContext:context];
                if (result == nil) {
                    result = [self insertInContext:context];
                    for (NSString *key in pairs) {
                        [result setValue:pairs[key] forKey:key];
                    }
                }
            }
        }
        else {
            NSString *details = [NSString stringWithFormat:@"Not found '%@' for '%@' in class: %@", kImportKey, kUniqueKey, NSStringFromClass([self class])];
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSExternalRecordImportError userInfo:@{NSLocalizedFailureReasonErrorKey: details}];
        }

        if (error == nil) {
           [result updateWithDictionary:dictionary error:&error];
        }
    }

    if (error && out_error) *out_error = error;
    return (error == nil) ? result : nil;
}

- (BOOL)updateWithDictionary:(NSDictionary *)dictionary error:(NSError **)out_error {
    NSError *error = nil;
    if ([dictionary isKindOfClass:[NSDictionary class]] == NO) {
        NSString *details = [NSString stringWithFormat:@"Invalid root import object (expected: %@, actual: %@) for class: %@", NSStringFromClass([NSDictionary class]), NSStringFromClass([dictionary class]), NSStringFromClass([self class])];
        error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSExternalRecordImportError userInfo:@{NSLocalizedFailureReasonErrorKey: details}];
    }
    else {
        [self updateAttributesWithDictionary:dictionary error:&error];
        [self updateRelationshipsWithDictionary:dictionary error:&error];
    }
    
    if (error && out_error) *out_error = error;
    return (error == nil);
}

- (BOOL)updateAttributesWithDictionary:(NSDictionary *)dictionary error:(NSError *__autoreleasing *)out_error {
    NSMutableArray *errors = [NSMutableArray array];
    NSDictionary *entityAttributes = [self.entity attributesByName];

    for (NSString *attributeName in entityAttributes) {
        NSAttributeDescription *attributeDescription = entityAttributes[attributeName];

        id importValue = nil;
        NSString *importKey = nil;
        for (NSString *key in attributeDescription.userInfo) {
            if ([key hasPrefix:kImportKey]) {
                importKey = attributeDescription.userInfo[key];
                importValue = dictionary[importKey];
                if (importValue != nil) {
                    break;
                }
            }
        }
        id value = importValue ? [[self class] transformImportValue:importValue importKey:importKey propertyDescription:attributeDescription] : nil;

        if (value != nil) {
            if (value == [NSNull null]) {
                [self setValue:nil forKey:attributeName];
            }
            else if (attributeDescription.attributeType == NSTransformableAttributeType) {
                [self setValue:value forKey:attributeName];
            }
            else {
                Class valueClass = NSClassFromString(attributeDescription.attributeValueClassName);
                if ([value isKindOfClass:valueClass]) {
                    [self setValue:value forKey:attributeName];
                }
                else if (valueClass == [NSDecimalNumber class] && [value isKindOfClass:[NSNumber class]]) {
                    [self setValue:[NSDecimalNumber decimalNumberWithDecimal:[value decimalValue]] forKey:attributeName];
                }
                else {
                    NSString *details = [NSString stringWithFormat:@"Invalid import value class (expected: %@, actual: %@) for key: '%@' in object: '%@'", attributeDescription.attributeValueClassName, NSStringFromClass([value class]), attributeName, NSStringFromClass([self class])];
                    [errors addObject:[NSError errorWithDomain:NSCocoaErrorDomain code:NSExternalRecordImportError userInfo:@{NSLocalizedFailureReasonErrorKey: details}]];
                }
            }
        }
    }

    NSError *error = nil;
    if (errors.count) {
        error = (errors.count == 1) ? [errors firstObject] : [NSError errorWithDomain:NSCocoaErrorDomain code:NSExternalRecordImportError userInfo:@{NSDetailedErrorsKey: errors}];
    }

    if (error && out_error) *out_error = error;
    return (error == nil);
}

- (BOOL)updateRelationshipsWithDictionary:(NSDictionary *)dictionary error:(NSError **)out_error {
    NSMutableArray *errors = [NSMutableArray array];
    NSDictionary *entityRelationships = [self.entity relationshipsByName];

    for (NSString *keyName in entityRelationships) {
        NSRelationshipDescription *relationshipDescription = entityRelationships[keyName];

        id importValue = nil;
        NSString *importKey = nil;
        for (NSString *key in relationshipDescription.userInfo) {
            if ([key hasPrefix:kImportKey]) {
                importKey = relationshipDescription.userInfo[key];
                importValue = dictionary[importKey];
                if (importValue != nil) {
                    break;
                }
            }
        }
        id value = importValue ? [[self class] transformImportValue:importValue importKey:importKey propertyDescription:relationshipDescription] : nil;

        if (value != nil) {
            Class valueClass = relationshipDescription.isToMany ? [NSArray class] : [NSDictionary class];
            Class relationClass = NSClassFromString(relationshipDescription.destinationEntity.managedObjectClassName);
            
            BOOL deleteOnReplace = [relationshipDescription.userInfo[kDeleteOnReplaceKey] boolValue];
            BOOL deleteNotUpdated = [relationshipDescription.userInfo[kDeleteNotUpdatedKey] boolValue];


            if (deleteOnReplace) {
                id value = [self valueForKey:keyName];
                if ([value isKindOfClass:[NSManagedObject class]]) {
                    [self.managedObjectContext deleteObject:value];
                }
                else { // assume that value is collection
                    for (NSManagedObject *obj in value) {
                        [self.managedObjectContext deleteObject:obj];
                    }
                }
            }

            if (value == [NSNull null]) {
                [self setValue:nil forKey:keyName];
            }
            else if ([value isKindOfClass:valueClass]) {
                NSError *error = nil;

                if (valueClass == [NSDictionary class]) {
                    NSManagedObject *object = nil;

                    if (relationshipDescription.inverseRelationship.isToMany) {
                        object = [relationClass updateChildObjectWithDictionary:(NSDictionary *)value parent:self inContext:[self managedObjectContext] error:&error];
                    }
                    else {
                        object = [self valueForKey:keyName];
                        if (object == nil) {
                            object = [relationClass updateChildObjectWithDictionary:(NSDictionary *)value parent:self inContext:[self managedObjectContext] error:&error];
                        }
                        else {
                            [object updateWithDictionary:(NSDictionary *)value error:&error];
                        }
                    }

                    if (error == nil) {
                        if (deleteNotUpdated) {
                            NSManagedObject *obj = [self valueForKey:keyName];
                            if (obj && [obj hasChanges] == NO) {
                                [[self managedObjectContext] deleteObject:obj];
                            }
                        }

                        [self setValue:object forKey:keyName];
                    }
                }
                else { //if (valueClass == [NSArray class]) {
                    id set = relationshipDescription.isOrdered ? [NSMutableOrderedSet new] : [NSMutableSet new];

                    for (NSDictionary *info in value) {
                        NSManagedObject *object = [relationClass updateChildObjectWithDictionary:(NSDictionary *)info parent:self inContext:[self managedObjectContext] error:&error];
                        if (object) [set addObject:object];
                        else break;
                    }

                    if (error == nil) {
                        if (deleteNotUpdated) {
                            id<NSFastEnumeration> collection = [self valueForKey:keyName];
                            for (NSManagedObject *obj in collection) {
                                if ([obj hasChanges] == NO) {
                                    [[self managedObjectContext] deleteObject:obj];
                                }
                            }
                        }

                        [self setValue:set forKey:keyName];
                    }
                }

                if (error) {
                    [errors addObject:error];
                    break;
                }
            }
            else if (valueClass == [NSDictionary class] && uniqueKeyForEntity(relationshipDescription.destinationEntity) != nil) {
                NSString *entityUniqueKey = uniqueKeyForEntity(relationshipDescription.destinationEntity);
                NSManagedObject *object = [relationClass entryWithValue:value forKey:entityUniqueKey includesPendingChanges:YES inContext:[self managedObjectContext]];
                [self setValue:object forKey:keyName];
            }
            else {
                NSString *details = [NSString stringWithFormat:@"Invalid import value class (expected: %@, actual: %@) for key: '%@' in object: '%@'", NSStringFromClass(valueClass), NSStringFromClass([value class]), keyName, NSStringFromClass([self class])];
                [errors addObject:[NSError errorWithDomain:NSCocoaErrorDomain code:NSExternalRecordImportError userInfo:@{NSLocalizedFailureReasonErrorKey: details}]];
            }
        }
    }

    NSError *error = nil;
    if (errors.count) {
        error = (errors.count == 1) ? [errors firstObject] : [NSError errorWithDomain:NSCocoaErrorDomain code:NSExternalRecordImportError userInfo:@{NSDetailedErrorsKey: errors}];
    }
    
    if (error && out_error) *out_error = error;
    return (error == nil);
}

#pragma mark - Export

+ (id)transformExportValue:(id)value exportKey:(NSString *)importKey propertyDescription:(NSPropertyDescription *)propertyDescription {
    return value ?: [NSNull null];
}

- (NSDictionary *)exportDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result addEntriesFromDictionary:[self exportAttributesDictionary]];
    [result addEntriesFromDictionary:[self exportRelationshipsDictionary]];
    return result;
}

- (NSDictionary *)exportAttributesDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    NSDictionary *entityAttributes = [self.entity attributesByName];
    for (NSString *keyName in entityAttributes) {
        NSAttributeDescription *attributeDescription = entityAttributes[keyName];
        
        NSString *exportKey = attributeDescription.userInfo[kExportKey];
        if (exportKey) {
            id value = [[self class] transformExportValue:[self valueForKey:keyName] exportKey:exportKey propertyDescription:attributeDescription];
            [result setValue:value forKey:exportKey];
        }
    }
    
    return result;
}

- (NSDictionary *)exportRelationshipsDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    NSDictionary *entityRelationships = [self.entity relationshipsByName];
    for (NSString *keyName in entityRelationships) {
        NSRelationshipDescription *relationshipDescription = entityRelationships[keyName];
        
        NSString *exportKey = relationshipDescription.userInfo[kExportKey];
        if (exportKey) {
            id value = [[self class] transformExportValue:[self valueForKey:keyName] exportKey:exportKey propertyDescription:relationshipDescription];
            
            if ([value isKindOfClass:[NSManagedObject class]]) { // usually 'one to one' relationship
                 [result setValue:[value exportDictionary] forKey:exportKey];
            }
            else if ([value isKindOfClass:[NSDictionary class]]) {
                [result setValue:value forKey:exportKey];
            }
            else if ([value conformsToProtocol:@protocol(NSFastEnumeration)]) { // Collection (NSSet, NSOrderedSet, NSArray)
                NSMutableArray *array = [NSMutableArray array];
                
                for (id innerObject in value) {
                    if ([innerObject isKindOfClass:[NSManagedObject class]]) {
                        NSDictionary *exportValue = [innerObject exportDictionary];
                        exportValue ? [array addObject:exportValue] : nil;
                    }
                    else {
                        [array addObject:innerObject];
                    }
                }
                
                [result setValue:array forKey:exportKey];
            }
            else { // any other object (NSNumber, NSNull, NSString)
                [result setValue:value forKey:exportKey];
            }
        }
    }
    
    return result;
}

@end
