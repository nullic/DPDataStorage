//
//  DPTypedContainerController.h
//  DPDataStorage
//
//  Created by Dmitriy Petrusevich on 9/13/19.
//  Copyright © 2019 dmitriy.petrusevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPDataSourceContainer.h"

NS_ASSUME_NONNULL_BEGIN

@interface DPTypedContainerController<__covariant ObjectType> : NSObject <DataSourceContainerController>
@property (nonatomic, readonly) NSArray<ObjectType> *fetchedObjects;

- (ObjectType _Nonnull)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath * _Nullable)indexPathForObject:(ObjectType)object;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (instancetype)initWithContainer:(id<DataSourceContainerController>)container;
@end

NS_ASSUME_NONNULL_END
