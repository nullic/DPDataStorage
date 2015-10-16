//
//  Programmer+CoreDataProperties.h
//  DPDataStorageDemo
//
//  Created by Alex Bakhtin on 10/16/15.
//  Copyright © 2015 dmitriy.petrusevich. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Programmer.h"

NS_ASSUME_NONNULL_BEGIN

@interface Programmer (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *platform;
@property (nullable, nonatomic, retain) Computer *computers;

@end

NS_ASSUME_NONNULL_END
