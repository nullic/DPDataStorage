//
//  ViewController.m
//  DPDataStorageDemo
//
//  Created by Alex Bakhtin on 10/6/15.
//  Copyright © 2015 dmitriy.petrusevich. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "Programmer.h"
#import "DPDataStorage.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet DPTableViewDataSource *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSManagedObjectContext *context = [[DPDataStorage defaultStorage] mainContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    self.dataSource.listController = [Programmer fetchedResultsController:self.dataSource predicate:nil
                                                          sortDescriptors:@[sortDescriptor] inContext:context];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kReusableCellIdentifier"];
    Programmer *programmer = [self.dataSource objectAtIndexPath:indexPath];
    cell.textLabel.text = programmer.name;
    return cell;
}

@end
