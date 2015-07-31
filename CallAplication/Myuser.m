//
//  Myuser.m
//  CallAplication
//
//  Created by David Tomic on 31/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "Myuser.h"
#import "SharedPreferences.h"

@implementation Myuser

static Myuser *myUser;

+(Myuser *)sharedUser
{
    if (!myUser) {
        myUser = [[Myuser alloc]init];
        [[SharedPreferences shared]loadUserData:myUser];
    }
    return myUser;
}

@end
