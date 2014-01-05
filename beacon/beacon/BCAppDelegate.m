//
//  BCAppDelegate.m
//  beacon
//
//  Created by Zac Bowling on 1/4/14.
//  Copyright (c) 2014 Hackathon. All rights reserved.
//

#import "BCAppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "BCBeaconManager.h"
#import <Parse/Parse.h>
#import <FYX/FYX.h>
#import <FYX/FYXLogging.h>

@interface BCAppDelegate()

@end

@implementation BCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"SXAlyPvRF4xtRiLIVngzYeJm5AQGXdfgaALNBfNm"
                  clientKey:@"OwosJG25H7m0iWIRlLB9uJTJMNGj2NNKHMyMpg9K"];

    [FYX setAppId:@"27370cf4d847cad118604f46c5bd14fcd5d16113c591aaf897ed9f38fe34d660"
        appSecret:@"65a10f43a079845ee83ed9a9c8d738908ff20076427ba2494383c6583c9c0ff9"
      callbackUrl:@"relate://auth"];

    [FYXLogging setLogLevel:FYX_LOG_LEVEL_INFO];

    [BCBeaconManager sharedManager];

    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
