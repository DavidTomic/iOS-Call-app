//
//  MyConnectionManager.m
//  CallAplication
//
//  Created by David Tomic on 30/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "MyConnectionManager.h"
#import "MyConnection.h"

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

-(void)logInAcountWithDelegate:(id)delegate selector:(SEL)selector phone:(NSString*)phone password:(NSString*)password{
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
    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?> \
                             <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"> \
                             <soap:Body> \
                             <RequestStatusInfo xmlns=\"http://tempuri.org/\"> \
                             <Phonenumber>%@</Phonenumber> \
                             <password>%@</password> \
                             </RequestStatusInfo> \
                             </soap:Body> \
                             </soap:Envelope>", @"0930001111", @"test"];
    
    [conn sendMessageWithMethodName:@"RequestStatusInfo" soapMessage:soapMessage];
}

//-(void)logInAcountWithDelegate:(id)delegate selector:(SEL)selector phone:(NSString*)phone password:(NSString*)password{
//    MyConnection *conn = [[MyConnection alloc]init];
//    conn.delegate = delegate;
//    conn.selector = selector;
//    
//    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?> \
//                             <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"> \
//                             <soap:Body> \
//                             <GetAccountSetup xmlns=\"http://tempuri.org/\"> \
//                             <Phonenumber>%@</Phonenumber> \
//                             <Password>%@</Password> \
//                             </GetAccountSetup> \
//                             </soap:Body> \
//                             </soap:Envelope>", @"385930001126", @"CallApp12345"];
//    
//    [conn sendMessageWithMethodName:@"GetAccountSetup" soapMessage:soapMessage];
//}

@end
