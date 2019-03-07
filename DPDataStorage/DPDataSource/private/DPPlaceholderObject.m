//
//  DPPlaceholderObject.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 2/4/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPPlaceholderObject.h"

@implementation DPPlaceholderObject
@end

@implementation DPDeletedPlaceholderObject
+ (instancetype)placeholderWithOriginalObject:(id)originalObject {
    DPDeletedPlaceholderObject *placeholderObject = [self new];
    placeholderObject.originalObject = originalObject;
    return placeholderObject;
}
@end
