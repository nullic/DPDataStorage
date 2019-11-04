//
//  NSManagedObjectModel+DataStorage.h
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 29/04/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectModel (EntityDescription)
- (NSString * _Nonnull)entityNameForManagedObjectClass:(Class _Nonnull)objectClass;
- (NSEntityDescription * _Nonnull)entityDescriptionForManagedObjectClass:(Class _Nonnull)objectClass;
@end
