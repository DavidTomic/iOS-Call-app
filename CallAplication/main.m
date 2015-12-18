//
//  main.m
//  CallAplication
//
//  Created by David Tomic on 27/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        
        NSLog(@"[NSLocale preferredLanguages] objectAtIndex:0] %@", [[NSLocale preferredLanguages] objectAtIndex:0]);
        
////        if (!([(NSString *)[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"en"] ||
////            [(NSString *)[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"da"])) {
////            [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"en", nil] forKey:@"AppleLanguages"];
////            [[NSUserDefaults standardUserDefaults] synchronize];
////        }
//        
//        if (!([(NSString *)[[NSLocale preferredLanguages] objectAtIndex:0] rangeOfString:@"en"].location != NSNotFound ||
//              [(NSString *)[[NSLocale preferredLanguages] objectAtIndex:0] rangeOfString:@"da"].location != NSNotFound)) {
//            
//            NSLog(@"HERE");
//            
//            [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"en", nil] forKey:@"AppleLanguages"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
