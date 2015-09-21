//
//  SharedPreferences.m
//  CallAplication
//
//  Created by David Tomic on 31/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "SharedPreferences.h"

@interface SharedPreferences(){
    NSUserDefaults *myDefaults;
}

@end


@implementation SharedPreferences

static SharedPreferences *sharedProperties;

+ (SharedPreferences *) shared {
    if(sharedProperties == nil)
        sharedProperties = [[SharedPreferences alloc] init];
    return sharedProperties;
}

- (id)init {
    self = [super init];
    if (self) {
        myDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}


-(void)saveUserData:(Myuser *)user{
    
    NSLog(@"phoneNumber %@", user.phoneNumber);
    
    [myDefaults setObject:user.phoneNumber forKey:@"phoneNumber"];
    [myDefaults setObject:user.password forKey:@"password"];
    [myDefaults setObject:user.name forKey:@"name"];
    [myDefaults setObject:user.email forKey:@"email"];
    [myDefaults setInteger:user.language forKey:@"language"];
    [myDefaults setObject:user.defaultText forKey:@"defaultText"];
    [myDefaults setBool:user.logedIn forKey:@"logedIn"];
    [myDefaults synchronize];
}

-(void)loadUserData:(Myuser *)user{
    
    user.phoneNumber = [myDefaults objectForKey:@"phoneNumber"];
    user.password = [myDefaults objectForKey:@"password"];
    user.name = [myDefaults objectForKey:@"name"];
    user.email = [myDefaults objectForKey:@"email"];
    user.language = [myDefaults integerForKey:@"language"];
    user.defaultText = [myDefaults objectForKey:@"defaultText"];
    user.logedIn = [myDefaults boolForKey:@"logedIn"];
    
}

-(void)setLastCallTime:(long long)time {
    [myDefaults  setObject:@(time) forKey:@"lastCallTime"];
    [myDefaults synchronize];
}
-(long long)getLastCallTime{
    long long time = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lastCallTime"] longLongValue];
    return time;
}

-(void)setLastContactsPhoneBookCount:(NSInteger)count{
    [myDefaults  setObject:@(count) forKey:@"lastContactsPhoneBookCount"];
    [myDefaults synchronize];
}
-(NSInteger)getLastContactsPhoneBookCount{
    NSInteger count = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lastContactsPhoneBookCount"] integerValue];
    return count;
}

@end
