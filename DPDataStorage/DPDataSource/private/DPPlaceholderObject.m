//
//  DPPlaceholderObject.m
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 2/4/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPPlaceholderObject.h"

@implementation DPBasePlaceholderObject
+ (instancetype)placeholderWithObject:(id)anObject {
    DPPlaceholderObject *placeholder = [self new];
    placeholder.anObject = anObject;
    return placeholder;
}
@end

@implementation DPPlaceholderObject
@end

@implementation DPDeletedPlaceholderObject
@end

@implementation DPInsertedPlaceholderObject
@end
