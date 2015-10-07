//
//  DPDataSourceCell.h
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 27/04/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

@protocol DPDataSourceCell <NSObject>
- (void)configureWithObject:(id)object;
@end
