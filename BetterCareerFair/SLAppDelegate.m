//
//  SLAppDelegate.m
//  BetterCareerFair
//
//  Created by Shao Ping Lee on 4/12/14.
//  Copyright (c) 2014 Shao-Ping Lee. All rights reserved.
//

#import "SLAppDelegate.h"
#import <FYX/FYX.h>

@implementation SLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FYX setAppId:@"7de3a00129e74dcd6f8774f412d3015064ada5c75dbbe28f8f8f15c81fcb7248"
        appSecret:@"b32e6d834b3e8f6ebe3a54d5352f422492314c8ab200cd3876c63d77ddf3c468"
      callbackUrl:@"test-gimbal://authcode"];
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:[NSString stringWithString:FYXHighAccuracyLocation] forKey:FYXLocationModeKey];
    [FYX enableLocationUpdatesWithOptions:options];
    [FYX startService:self];
    return YES;
}

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
    if (url != nil && [url isFileURL]) {
        [(UITabBarController *)self.window.rootViewController setSelectedIndex:1];
        [[(UITabBarController *)self.window.rootViewController childViewControllers][1] handleDocumentOpenURL:url];
    }
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

- (void)serviceStarted
{
    // this will be invoked if the service has successfully started
    // bluetooth scanning will be started at this point.
    NSLog(@"FYX Service Successfully Started");
}

- (void)startServiceFailed:(NSError *)error
{
    // this will be called if the service has failed to start
    NSLog(@"%@", error);
}

@end
