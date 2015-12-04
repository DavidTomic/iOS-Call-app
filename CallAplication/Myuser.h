//
//  Myuser.h
//  CallAplication
//
//  Created by David Tomic on 31/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyLanguage.h"
#import "MyStatus.h"

@interface Myuser : NSObject

+(Myuser *) sharedUser;

@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic) Language language;
@property (nonatomic) BOOL logedIn;

@property (nonatomic) Status status;
@property (nonatomic, strong) NSString *statusText;

@property (nonatomic, strong) NSString *smsInviteText;
@property (nonatomic, strong) NSString *statusStartTime;
@property (nonatomic, strong) NSString *statusEndTime;

@property (nonatomic) Status timerStatus;
@property (nonatomic, strong) NSString *timerStatusText;

@property (nonatomic, strong) NSMutableDictionary *contactDictionary;
//@property (nonatomic, strong) NSMutableArray *checkPhoneNumberArray;



@property (nonatomic) int lastDialedRecordId;
@property (nonatomic, strong) NSString *lastDialedPhoneNumber;

@property (nonatomic) NSInteger requestStatusInfoSeconds;

@end
