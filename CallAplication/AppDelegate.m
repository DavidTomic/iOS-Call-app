//
//  AppDelegate.m
//  CallAplication
//
//  Created by David Tomic on 27/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "AppDelegate.h"
#import "Myuser.h"
#import "DBManager.h"
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@interface AppDelegate ()

@property (nonatomic, strong) CTCallCenter *callCenter1;
//@property (nonatomic, strong) CTCallCenter *callCenter2;

//@property (nonatomic) BOOL processingOtherStatesActive;
//@property (nonatomic, strong) NSMutableArray *states;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Fabric with:@[[Crashlytics class]]];


    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:1.0f]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    [self.window setTintColor:[UIColor colorWithRed:0/255.0f green:93/255.0f blue:193/255.0f alpha:1.0f]];

    
    void (^block)(CTCall*) = ^(CTCall* call) {
        
        NSString *state;
        
        if ([call.callState isEqualToString: CTCallStateConnected]) {
            state = @"Connected";
        } else if ([call.callState isEqualToString: CTCallStateDialing]) {
            state = @"Dialing";
        } else if ([call.callState isEqualToString: CTCallStateDisconnected]) {
            state = @"Disconnected";
        } else if ([call.callState isEqualToString: CTCallStateIncoming]) {
            state = @"Incomming";
            return;
        }
        
        NSLog(@"STATE %@", state);
        
        if ([state isEqualToString:@"Dialing"]) {
                [self processDialState];
        }
        
        
//        if (![self.states containsObject:state]) {
//            [self.states addObject:state];
//            
//            if ([state isEqualToString:@"Dialing"]) {
//                [self processDialState];
//            }else{
//                if(self.processingOtherStatesActive)
//                    return;
//                
//                self.processingOtherStatesActive = YES;
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self performSelector:@selector(processOtherStates) withObject:self afterDelay:0.5];
//                });
//            }
//        }
        
    };

    self.callCenter1 = [[CTCallCenter alloc] init];
    self.callCenter1.callEventHandler = block;
    
//    self.callCenter2 = [[CTCallCenter alloc] init];
//    self.callCenter2.callEventHandler = block;
    
    return YES;
}

//-(NSMutableArray *)states{
//    
//    if(!_states) _states = [[NSMutableArray alloc]init];
//    
//    return _states;
//}

-(void)processDialState{
   // NSLog(@"processState %@", self.states);
    
    NSLog(@"[Myuser sharedUser].lastDialedRecordId %d", [Myuser sharedUser].lastDialedRecordId);
    NSLog(@"[Myuser sharedUser].lastDialedPhoneNumber %@", [Myuser sharedUser].lastDialedPhoneNumber);
    
    if([Myuser sharedUser].lastDialedRecordId && [Myuser sharedUser].lastDialedRecordId !=0){
        [[DBManager sharedInstance]addContactInRecentWithRecordId:[Myuser sharedUser].lastDialedRecordId phoneNumber:nil timestamp:(long long)([[NSDate date] timeIntervalSince1970] * 1000.0)];
    }else if([Myuser sharedUser].lastDialedPhoneNumber){
        [[DBManager sharedInstance]addContactInRecentWithRecordId:0 phoneNumber:[Myuser sharedUser].lastDialedPhoneNumber timestamp:(long long)([[NSDate date] timeIntervalSince1970] * 1000.0)];
    }
    
    [Myuser sharedUser].lastDialedPhoneNumber = nil;
    [Myuser sharedUser].lastDialedRecordId = 0;

}

//-(void)processOtherStates{
//    NSLog(@"processOtherStates %@", self.states);
//    
//    self.processingOtherStatesActive = NO;
//    [self.states removeAllObjects];
//    
//}


-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    Myuser *user = [Myuser sharedUser];
    if (user!=nil && user.logedIn) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"tab bar"];
        self.window.rootViewController = rootViewController;
        [self.window makeKeyAndVisible];
    }
    
//    NSLocale *locale = [NSLocale currentLocale];
//    NSString *language = [locale displayNameForKey:NSLocaleIdentifier
//                                             value:[locale localeIdentifier]];
//    NSLog(@"language %@", language);
//    NSLog(@"language code %@", [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]);
//    NSLog(@"preferredlanguage code %@", [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0]);
    
    


    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //NSLog(@"applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
 //    [self.states removeAllObjects];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
     NSLog(@"applicationWillEnterForeground");

 //   [Myuser sharedUser].lastDialedPhoneNumber = nil;
 //   [Myuser sharedUser].lastDialedRecordId = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
 //   [Myuser sharedUser].lastDialedPhoneNumber = nil;
 //   [Myuser sharedUser].lastDialedRecordId = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
 //   NSLog(@"applicationWillTerminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
