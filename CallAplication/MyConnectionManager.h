//
//  MyConnectionManager.h
//  CallAplication
//
//  Created by David Tomic on 30/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyConnectionManager : NSObject

+(MyConnectionManager *) sharedManager;
+(void)Empty;

-(void)testHelloWorldWithDelegate:(id)delegate selector:(SEL)selector;

-(void)createAcountWithDelegate:(id)delegate selector:(SEL)selector phone:(NSString*)phone password:(NSString*)password name:(NSString*)name email:(NSString *)email language:(int)language;
-(void)getAcountSetupWithDelegate:(id)delegate selector:(SEL)selector phone:(NSString*)phone password:(NSString*)password;

-(void)requestStatusInfoWithDelegate:(id)delegate selector:(SEL)selector;
-(void)requestDefaultTextsWithDelegate:(id)delegate selector:(SEL)selector;
-(void)requestLogInWithDelegate:(id)delegate selector:(SEL)selector;
-(void)requestAddContactsWithDelegate:(id)delegate selector:(SEL)selector;

@end
