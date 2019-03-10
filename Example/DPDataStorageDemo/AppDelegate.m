//
//  AppDelegate.m
//  DPDataStorageDemo
//
//  Created by Alex Bakhtin on 10/6/15.
//  Copyright © 2015 dmitriy.petrusevich. All rights reserved.
//

#import "AppDelegate.h"
#import <DPDataStorage/DPDataStorage.h>
#import "Programmer+CoreDataProperties.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // DPDataStorage default storage setup.
    [DPDataStorage setupDefaultStorageWithModelName:nil storageURL:[DPDataStorage storageDefaultURL]];
    [self addExampleObjects];

//    DPArrayController *ctrl =[DPArrayController new];
//    [ctrl insertObject:@1 atIndextPath:[NSIndexPath indexPathForRow:2 inSection:0]];
//    [ctrl insertObject:@2 atIndextPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    [ctrl insertObject:@3 atIndextPath:[NSIndexPath indexPathForRow:1 inSection:0]];

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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSManagedObjectContext *context = [[DPDataStorage defaultStorage] newPrivateQueueManagedObjectContext];
        [context performBlock:^{
            if (0) {
                [Programmer deleteAllEntriesInContext:context];
            }
            else {
                NSArray *entries = [Programmer allEntriesInContext:context];
                for (Programmer *p in entries) {
                    if ([p.name isEqualToString:@"programmer1"]) {
                        [context deleteObject:p];
                    }
                    if ([p.name isEqualToString:@"programmer3"]) {
                        p.date = [NSDate date];
                    }
                }

                Programmer *programmer1 = [Programmer insertInContext:context];
                programmer1.name = @"programmer1";
                programmer1.date = [NSDate date];
//                Programmer *programmer2 = [Programmer insertInContext:context];
//                programmer2.name = @"programmer2";
//                programmer2.date = [NSDate date];
//                Programmer *programmer3 = [Programmer insertInContext:context];
//                programmer3.name = @"programmer2";
//                programmer3.date = [NSDate date];
//                Programmer *programmer4 = [Programmer insertInContext:context];
//                programmer4.name = @"programmer3";
//                programmer4.date = [NSDate date];
            }
            
            NSError *error = nil;
            [context saveChanges:&error];
        }];
    });
}

@end
