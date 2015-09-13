//
//  InternetStatus.m
//  CallAplication
//
//  Created by David Tomic on 13/09/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "InternetStatus.h"
#import <SystemConfiguration/SCNetworkReachability.h>

@implementation InternetStatus

+(bool)isNetworkAvailable
{
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityRef address;
    address = SCNetworkReachabilityCreateWithName(NULL, "www.apple.com" );
    Boolean success = SCNetworkReachabilityGetFlags(address, &flags);
    CFRelease(address);
    
    bool canReach = success
    && !(flags & kSCNetworkReachabilityFlagsConnectionRequired)
    && (flags & kSCNetworkReachabilityFlagsReachable);
    
    return canReach;
}

@end
