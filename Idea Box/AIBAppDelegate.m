//
//  AIBAppDelegate.m
//  Idea Box
//
//  Created by Thomas Dimson on 12/24/13.
//  Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "AIBAppDelegate.h"
#import "AIBConstants.h"
#import "Dropbox/Dropbox.h"
#import "Appirater.h"
//#import <TestFlight.h>
#import <Crashlytics/Crashlytics.h>

@implementation AIBAppDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
        sourceApplication:(NSString *)sourceApplication
               annotation:(id)annotation {
    if([sourceApplication isEqualToString:@"com.getdropbox.Dropbox"]) {
        DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAIBDropboxOpenURLOccurred object:nil];
        if(account) {
            return YES;
        }
        return NO;
    }

    return NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DBAccountManager *accountManager = [[DBAccountManager alloc]
            initWithAppKey:kAIBDropboxApiKey secret:kAIBDropboxApiSecret];
    [DBAccountManager setSharedManager:accountManager];
    //[TestFlight takeOff:kAIBTestflightApiKey];
    [Crashlytics startWithAPIKey:kAIBCrashlyticsKey];
    [Appirater setAppId:kAIBAppStoreId];
    [Appirater setDaysUntilPrompt:1];
    [Appirater setUsesUntilPrompt:7];
    [Appirater setTimeBeforeReminding:2];
    [Appirater appLaunched:YES];
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

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [Appirater appEnteredForeground:YES];
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
