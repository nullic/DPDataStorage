//
//  DPTableViewDataSource.h
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 17/03/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "DPBaseDataSource.h"

@interface DPTableViewDataSource : DPBaseDataSource <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, copy) IBInspectable NSString * _Nullable cellIdentifier; // Cell must conform <DPDataSourceCell>
@property (nonatomic) IBInspectable BOOL disableAnimations;

- (NSInteger)numberOfSectionsInTableView:(UITableView * _Nullable)tableView;
- (NSInteger)tableView:(UITableView * _Nullable)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell * _Nonnull)tableView:(UITableView * _Nullable)tableView cellForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
@end
