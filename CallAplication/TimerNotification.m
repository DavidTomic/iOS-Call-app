//
//  TimerNotification.m
//  CallAplication
//
//  Created by David Tomic on 24/11/15.
//  Copyright © 2015 David Tomic. All rights reserved.
//

#import "TimerNotification.h"
#import "Myuser.h"
#import "SharedPreferences.h"

@implementation TimerNotification

+(void)setTimerNotification{
    [self setStartTimerNotification];
    [self setEndTimerNotification];
}

+(void)setStartTimerNotification{
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *statusStartTime = [df dateFromString: [Myuser sharedUser].statusStartTime];
    
//    NSLog(@"statusStartTime %@", [Myuser sharedUser].statusStartTime);
//    NSLog(@"currentDate %@", [df stringFromDate:currentDate]);
//    
    NSTimeInterval secs = [statusStartTime timeIntervalSinceDate:currentDate];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secs * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // TO DO METHOD CALL.
        NSLog(@"RefreshStatus statusStartTime");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshStatus"
                                                            object:self];
    });
}

+(void)setEndTimerNotification{
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *statusStartTime = [df dateFromString: [Myuser sharedUser].statusEndTime];
    
    NSTimeInterval secs = [statusStartTime timeIntervalSinceDate:currentDate];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secs * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // TO DO METHOD CALL.
        NSLog(@"RefreshStatus statusEndTime");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshStatus"
                                                            object:self];
    });
}

+(void)cancelTimerNotification{
    Myuser *user = [Myuser sharedUser];
    user.statusStartTime = @"2000-01-01T00:00:00";
    user.statusEndTime = @"2000-01-01T00:00:00";
    
    [[SharedPreferences shared]saveUserData:[Myuser sharedUser]];
}

@end
