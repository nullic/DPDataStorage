//
//  ViewController.m
//  DPDataStorageDemo
//
//  Created by Alex Bakhtin on 10/6/15.
//  Copyright © 2015 dmitriy.petrusevich. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import <DPDataStorage/DPDataStorage.h>
#import "Programmer+CoreDataProperties.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet DPTableViewDataSource *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSManagedObjectContext *context = [[DPDataStorage defaultStorage] mainContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSSortDescriptor *sortById = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    
    NSFetchRequest *fetchRequest = [Programmer newFetchRequestInContext:context];
    [fetchRequest setSortDescriptors:@[sortDescriptor, sortById]];

    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:context
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    fetchedResultsController.delegate = self.dataSource;
    [fetchedResultsController performFetch:NULL];
    
    self.dataSource.listController = [[DPSectionedFetchedResultsController alloc] initWithDelegate:self.dataSource sectionKeyPath:@"name" sectionSortDescriptor:sortDescriptor frc:fetchedResultsController];
//    self.dataSource.listController = [[DPContainerControllerBasedController alloc] initWithDelegate:self.dataSource otherController:fetchedResultsController];
    
//    self.dataSource.listController = fetchedResultsController;
//    self.dataSource.listController = [Programmer fetchedResultsController:self.dataSource predicate:nil
//                                                          sortDescriptors:@[sortDescriptor] inContext:context];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kReusableCellIdentifier"];
    Programmer *programmer = [self.dataSource objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", programmer.name, [programmer.objectID URIRepresentation].lastPathComponent];
    return cell;
}

@end
