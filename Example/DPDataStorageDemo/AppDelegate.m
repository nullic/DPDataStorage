//
//  AppDelegate.m
//  DPDataStorageDemo
//
//  Created by Alex Bakhtin on 10/6/15.
//  Copyright © 2015 dmitriy.petrusevich. All rights reserved.
//

#import "AppDelegate.h"
#import <DPDataStorage/DPDataStorage.h>
#import "Programmer.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // DPDataStorage default storage setup.
    [DPDataStorage setupDefaultStorageWithModelName:nil storageURL:[DPDataStorage storageDefaultURL]];
    [self addExampleObjects];

    DPArrayController *ctrl = [DPArrayController new];
    [ctrl insertObject:@1 atIndextPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [ctrl insertObject:@2 atIndextPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [ctrl insertObject:@3 atIndextPath:[NSIndexPath indexPathForRow:1 inSection:0]];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}


- (void)addExampleObjects {
    NSManagedObjectContext *context = [[DPDataStorage defaultStorage] newPrivateQueueManagedObjectContext];
    [context performBlock:^{
        Programmer *programmer1 = [Programmer insertInContext:context];
        programmer1.name = @"programmer1";
        Programmer *programmer2 = [Programmer insertInContext:context];
        programmer2.name = @"programmer2";
        Programmer *programmer3 = [Programmer insertInContext:context];
        programmer3.name = @"programmer3";
        NSError *error = nil;
        [context saveChanges:&error];
    }];
}

@end
