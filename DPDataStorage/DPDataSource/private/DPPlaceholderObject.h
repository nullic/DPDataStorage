//
//  DPPlaceholderObject.h
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 2/4/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DPBasePlaceholderObject : NSObject
@property (nonatomic, strong, nullable) id anObject;
+ (instancetype)placeholderWithObject:(id)anObject;
@end

@interface DPPlaceholderObject : DPBasePlaceholderObject
@end

@interface DPDeletedPlaceholderObject : DPBasePlaceholderObject
@end

@interface DPInsertedPlaceholderObject : DPBasePlaceholderObject
@end

NS_ASSUME_NONNULL_END
