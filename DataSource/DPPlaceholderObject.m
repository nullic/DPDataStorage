//
//  DPPlaceholderObject.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 2/4/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPPendingObject.h"

@implementation DPPendingObject

+ (instancetype)objectWithObject:(id)anObject index:(NSInteger)index {
    NSParameterAssert([anObject isKindOfClass:[DPPendingObject class]] == NO);
    
    DPPendingObject *placeholder = [self new];
    placeholder.anObject = anObject;
    placeholder.index = index;
    return placeholder;
}

@end
