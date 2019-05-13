//
//  DPPlaceholderObject.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 2/4/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPPlaceholderObject.h"

@implementation DPPlaceholderObject
+ (instancetype)placeholderWithObject:(id)anObject {
    NSParameterAssert([anObject isKindOfClass:[DPPlaceholderObject class]] == NO);
    
    DPPlaceholderObject *placeholder = [self new];
    placeholder.anObject = anObject;
    return placeholder;
}
@end

@implementation DPInsertedPlaceholderObject
@end

@implementation DPDeletedPlaceholderObject
@end
