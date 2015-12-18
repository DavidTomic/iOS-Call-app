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

-(void)setVoiceMailNumber:(NSString *)number;
-(NSString *)getVoiceMailNumber;

-(void)setLastCallTime:(NSString *)executionTime;
-(NSString *)getLastCallTime;

-(void)setContactNumbersArray:(NSArray *)array;
-(NSArray *)getContactNumbersArray;

-(NSArray *)getContactNamesArray;
-(void)setContactNamesArray:(NSArray *)array;
@end
