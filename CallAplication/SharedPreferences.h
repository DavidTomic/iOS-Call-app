//
//  SharedPreferences.h
//  CallAplication
//
//  Created by David Tomic on 31/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Myuser.h"

@interface SharedPreferences : NSObject

+ (SharedPreferences *) shared;

-(void)saveUserData:(Myuser *)user;
-(void)loadUserData:(Myuser *)user;

-(void)setLastCallTime:(long long)time;
-(long long)getLastCallTime;

-(void)setLastContactsPhoneBookCount:(NSInteger)count;
-(NSInteger)getLastContactsPhoneBookCount;

-(void)setVoiceMailNumber:(NSString *)number;
-(NSString *)getVoiceMailNumber;

@end
