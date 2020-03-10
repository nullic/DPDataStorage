//
//  DPPlaceholderObject.h
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 2/4/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DPPendingObject : NSObject
@property (nonatomic, strong, nullable) id anObject;
@property (nonatomic, assign) NSInteger index;
+ (instancetype)objectWithObject:(nullable id)anObject index:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
