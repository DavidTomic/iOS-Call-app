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
    
   // NSLog(@"phoneNumber %@", user.phoneNumber);
    
    [myDefaults setObject:user.phoneNumber forKey:@"phoneNumber"];
    [myDefaults setObject:user.password forKey:@"password"];
    [myDefaults setObject:user.name forKey:@"name"];
    [myDefaults setObject:user.email forKey:@"email"];
    [myDefaults setInteger:user.language forKey:@"language"];
    [myDefaults setObject:user.statusText forKey:@"statusText"];
    [myDefaults setBool:user.logedIn forKey:@"logedIn"];
    [myDefaults setInteger:user.status forKey:@"status"];
    [myDefaults setObject:user.smsInviteText forKey:@"smsInviteText"];
    [myDefaults setObject:user.statusStartTime forKey:@"statusStartTime"];
    [myDefaults setObject:user.statusEndTime forKey:@"statusEndTime"];
    [myDefaults setInteger:user.timerStatus forKey:@"timerStatus"];
    [myDefaults setObject:user.timerStatusText forKey:@"timerStatusText"];
    [myDefaults setInteger:user.requestStatusInfoSeconds forKey:@"requestStatusInfoSeconds"];
    [myDefaults synchronize];
}

-(void)loadUserData:(Myuser *)user{
    
    user.phoneNumber = [myDefaults objectForKey:@"phoneNumber"];
    user.password = [myDefaults objectForKey:@"password"];
    user.name = [myDefaults objectForKey:@"name"];
    user.email = [myDefaults objectForKey:@"email"];
    user.language = [myDefaults integerForKey:@"language"];
    user.statusText = [myDefaults objectForKey:@"statusText"];
    user.logedIn = [myDefaults boolForKey:@"logedIn"];
    user.status = [myDefaults integerForKey:@"status"];
    user.smsInviteText = [myDefaults objectForKey:@"smsInviteText"];
    user.statusStartTime = [myDefaults objectForKey:@"statusStartTime"];
    user.statusEndTime = [myDefaults objectForKey:@"statusEndTime"];
    user.timerStatus = [myDefaults integerForKey:@"timerStatus"];
    user.timerStatusText = [myDefaults objectForKey:@"timerStatusText"];
    user.requestStatusInfoSeconds = [myDefaults integerForKey:@"requestStatusInfoSeconds"];
}

-(void)setLastCallTime:(NSString *)executionTime {
    [myDefaults setObject:executionTime forKey:@"executionTime"];
    [myDefaults synchronize];
}
-(NSString *)getLastCallTime{
    NSString *executionTime = [myDefaults objectForKey:@"executionTime"];
    
    if (!executionTime) {
        executionTime = @"2000-01-01T00:00:00";
    }
    
    return executionTime;
}

-(void)setLastContactsPhoneBookCount:(NSInteger)count{
    [myDefaults  setObject:@(count) forKey:@"lastContactsPhoneBookCount"];
    [myDefaults synchronize];
}
-(NSInteger)getLastContactsPhoneBookCount{
    NSInteger count = [[myDefaults objectForKey:@"lastContactsPhoneBookCount"] integerValue];
    return count;
}

-(void)setVoiceMailNumber:(NSString *)number {
    [myDefaults  setObject:number forKey:@"voiceMailNumber"];
    [myDefaults synchronize];
}
-(NSString *)getVoiceMailNumber{
    NSString *number = [myDefaults objectForKey:@"voiceMailNumber"];
    return number;
}

@end
