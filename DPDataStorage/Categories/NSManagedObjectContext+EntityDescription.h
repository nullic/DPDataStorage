//
//  NSManagedObjectContext.h
//  DPDataStorage
//
//  Created by Alexey Bakhtin on 12/22/18.
//  Copyright © 2018 Dmitriy Petrusevich. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSManagedObjectContext (EntityDescription)

- (NSString *)entityNameForManagedObjectClass:(Class)objectClass;
- (NSEntityDescription *)entityDescriptionForManagedObjectClass:(Class)objectClass;

@end

NS_ASSUME_NONNULL_END
