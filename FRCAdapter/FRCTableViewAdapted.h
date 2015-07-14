//
//  FRCTableVeiwAdapted.h
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 17/03/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRCBaseAdapter.h"
#import "FRCAdaptedCell.h"

@interface FRCTableViewAdapted : FRCBaseAdapter <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, copy) IBInspectable NSString *cellIdentifier; // Cell must conform <FRCAdaptedCell>
@property (nonatomic) IBInspectable BOOL disableAnimations;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
