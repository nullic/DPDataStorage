//
//  NSManagedObjectContext.m
//  DPDataStorage
//
//  Created by Alexey Bakhtin on 12/22/18.
//  Copyright © 2018 EffectiveSoft. All rights reserved.
//

#import "NSManagedObjectContext+DPDataStorage_Mapping.h"
#import <objc/runtime.h>

@implementation NSManagedObjectContext (DPDataStorage_Mapping)

static NSString * const kParseDataHasDuplicatesKey = @"parseDataHasDuplicates";
static NSString * const kParseFullGraphKey = @"parseFullGraph";

- (void)setParseDataHasDuplicates:(BOOL)parseDataHasDuplicates {
    objc_setAssociatedObject(self, (__bridge void *)(kParseDataHasDuplicatesKey), @(parseDataHasDuplicates), OBJC_ASSOCIATION_RETAIN);
}
    
- (BOOL)parseDataHasDuplicates {
    return [(objc_getAssociatedObject(self, (__bridge const void *)(kParseDataHasDuplicatesKey)) ?: @YES) boolValue];
}

- (void)setParseFullGraphKey:(BOOL)parseFullGraphKey {
    objc_setAssociatedObject(self, (__bridge void *)(kParseFullGraphKey), @(parseFullGraphKey), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)parseFullGraphKey {
    return [(objc_getAssociatedObject(self, (__bridge const void *)(kParseFullGraphKey)) ?: @YES) boolValue];
}

@end
