//
//  NSManagedObjectContext.h
//  DPDataStorage
//
//  Created by Alexey Bakhtin on 12/22/18.
//  Copyright © 2018 EffectiveSoft. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSManagedObjectContext (DPDataStorage_Mapping)

@property (nonatomic) BOOL parseDataHasDuplicates;
@property (nonatomic) BOOL parseFullGraphKey;

@end

NS_ASSUME_NONNULL_END
