//
//  NSManagedObjectModel+DataStorage.h
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 29/04/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NSManagedObject+DPDataStorage_Mapping.h"

@interface NSManagedObjectModel (DataStorage)
- (NSString *)entityNameForManagedObjectClass:(Class)objectClass;
- (NSEntityDescription *)entityDescriptionForManagedObjectClass:(Class)objectClass;
@end
