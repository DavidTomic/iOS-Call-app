//
//  MyConnectionManager.m
//  CallAplication
//
//  Created by David Tomic on 30/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "MyConnectionManager.h"
#import "MyConnection.h"
#import "Myuser.h"
#import "SharedPreferences.h"

@implementation MyConnectionManager


static MyConnectionManager *mySharedManager;
+(MyConnectionManager *) sharedManager
{
    if (!mySharedManager) {
        mySharedManager = [[MyConnectionManager alloc]init];
    }
    return mySharedManager;
}

+(void)Empty{
    mySharedManager = nil;
}
-(void)testHelloWorldWithDelegate:(id)delegate selector:(SEL)selector{
    
    MyConnection *conn = [[MyConnection alloc]init];
    conn.delegate = delegate;
    conn.selector = selector;
    
    NSString *soapMessage = @"<?xml version=\"1.0\" encoding=\"utf-8\"?> \
    <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"> \
    <soap:Body> \
    <HelloWorld xmlns=\"http://tempuri.org/\" /> \
    </soap:Body> \
    </soap:Envelope>";
    
    [conn sendMessageWithMethodName:@"HelloWorld" soapMessage:soapMessage];
}


-(void)createAcountWithDelegate:(id)delegate selector:(SEL)selector phone:(NSString*)phone password:(NSString*)password name:(NSString*)name email:(NSString *)email language:(int)language {
    MyConnection *conn = [[MyConnection alloc]init];
    conn.delegate = delegate;
    conn.selector = selector;
    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?> \
    <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"> \
    <soap:Body> \
    <CreateAccount xmlns=\"http://tempuri.org/\"> \
    <Phonenumber>%@</Phonenumber> \
    <password>%@</password> \
    <Name>%@</Name> \
    <Email>%@</Email> \
    <Language>%d</Language> \
    <Allowmode>0</Allowmode> \
    </CreateAccount> \
    </soap:Body> \
    </soap:Envelope>", phone, password, name, email, language];
    
    [conn sendMessageWithMethodName:@"CreateAccount" soapMessage:soapMessage];
}

-(void)getAcountSetupWithDelegate:(id)delegate selector:(SEL)selector phone:(NSString*)phone password:(NSString*)password{
    MyConnection *conn = [[MyConnection alloc]init];
    conn.delegate = delegate;
    conn.selector = selector;
    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?> \
                             <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"> \
                             <soap:Body> \
                             <GetAccountSetup xmlns=\"http://tempuri.org/\"> \
                             <Phonenumber>%@</Phonenumber> \
                             <Password>%@</Password> \
                             </GetAccountSetup> \
                             </soap:Body> \
                             </soap:Envelope>", phone, password];
    
    [conn sendMessageWithMethodName:@"GetAccountSetup" soapMessage:soapMessage];
}

-(void)requestStatusInfoWithDelegate:(id)delegate selector:(SEL)selector{
    MyConnection *conn = [[MyConnection alloc]init];
    conn.delegate = delegate;
    conn.selector = selector;
    
    Myuser *user = [Myuser sharedUser];
    long long lastCallTime = [[SharedPreferences shared]getLastCallTime];
    NSString *date = @"2000-01-01T00:00:00";
    
    if (lastCallTime != 0) {
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        date = [[dateFormater stringFromDate:[NSDate dateWithTimeIntervalSince1970:lastCallTime/1000]] uppercaseString];
    }
    
    [[SharedPreferences shared]setLastCallTime:(long long)([[NSDate date] timeIntervalSince1970] * 1000.0)];
    
    NSLog(@"lastCallDate %@", date);
    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?> \
                             <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"> \
                             <soap:Body> \
                             <RequestStatusInfo xmlns=\"http://tempuri.org/\"> \
                             <Phonenumber>%@</Phonenumber> \
                             <password>%@</password> \
                             <LastCall>%@</LastCall> \
                             </RequestStatusInfo> \
                             </soap:Body> \
                             </soap:Envelope>", user.phoneNumber, user.password, date];
    
    [conn sendMessageWithMethodName:@"RequestStatusInfo" soapMessage:soapMessage];
}


@end
