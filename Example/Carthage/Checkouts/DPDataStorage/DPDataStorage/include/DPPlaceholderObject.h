//
//  DPPlaceholderObject.h
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 2/4/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DPPlaceholderObject : NSObject
@property (nonatomic, strong, nullable) id anObject;
+ (instancetype)placeholderWithObject:(nullable id)anObject;
@end

@interface DPInsertedPlaceholderObject : DPPlaceholderObject
@end

@interface DPDeletedPlaceholderObject : DPPlaceholderObject
@end

NS_ASSUME_NONNULL_END
