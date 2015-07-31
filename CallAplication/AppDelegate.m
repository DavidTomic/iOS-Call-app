//
//  AppDelegate.m
//  CallAplication
//
//  Created by David Tomic on 27/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "AppDelegate.h"
#import "Myuser.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.callCenter = [[CTCallCenter alloc] init];
    [self registerForCalls];
    
    return YES;
}

- (void) registerForCalls {
    
    
    NSLog(@"registering for call center events");
    [self.callCenter setCallEventHandler: ^(CTCall* call) {
        
        NSLog(@"Event handler called");
        if ([call.callState isEqualToString: CTCallStateConnected]) {
            NSLog(@"Connected");
        } else if ([call.callState isEqualToString: CTCallStateDialing]) {
            NSLog(@"Dialing");
        } else if ([call.callState isEqualToString: CTCallStateDisconnected]) {
            NSLog(@"Disconnected");
        } else if ([call.callState isEqualToString: CTCallStateIncoming]) {
            NSLog(@"Incomming");
        }
        NSLog(@"\n\n callEventHandler: %@ \n\n", call.callState);
    }];
}

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    Myuser *user = [Myuser sharedUser];
    if (user!=nil && user.logedIn) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"tab bar"];
        self.window.rootViewController = rootViewController;
        [self.window makeKeyAndVisible];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"applicationWillTerminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
