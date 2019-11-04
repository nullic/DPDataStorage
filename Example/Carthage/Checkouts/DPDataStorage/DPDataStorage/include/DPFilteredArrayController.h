//
//  DPFilteredArrayController.h
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 1/8/19.
//  Copyright © 2019 EffectiveSoft. All rights reserved.
//

#import "DPArrayController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DPFilteredArrayController : DPArrayController
@property (nonatomic, strong, nullable) NSPredicate *filter;
@end

NS_ASSUME_NONNULL_END
