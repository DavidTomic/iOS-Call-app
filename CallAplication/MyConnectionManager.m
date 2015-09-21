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
#import "Contact.h"

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

-(void)requestDefaultTextsWithDelegate:(id)delegate selector:(SEL)selector{
    MyConnection *conn = [[MyConnection alloc]init];
    conn.delegate = delegate;
    conn.selector = selector;
    
    Myuser *user = [Myuser sharedUser];
    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?> \
                             <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"> \
                             <soap:Body> \
                             <GetDefaultText xmlns=\"http://tempuri.org/\"> \
                             <Phonenumber>%@</Phonenumber> \
                             <password>%@</password> \
                             </GetDefaultText> \
                             </soap:Body> \
                             </soap:Envelope>", user.phoneNumber, user.password];
    
    [conn sendMessageWithMethodName:@"GetDefaultText" soapMessage:soapMessage];
}

-(void)requestLogInWithDelegate:(id)delegate selector:(SEL)selector{
    MyConnection *conn = [[MyConnection alloc]init];
    conn.delegate = delegate;
    conn.selector = selector;
    
    Myuser *user = [Myuser sharedUser];
    
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?> \
                             <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"> \
                             <soap:Body> \
                             <Login xmlns=\"http://tempuri.org/\"> \
                             <Phonenumber>%@</Phonenumber> \
                             <Password>%@</Password> \
                             <VersionNumber>%@</VersionNumber> \
                             <AppType>%d</AppType> \
                             </Login> \
                             </soap:Body> \
                             </soap:Envelope>", user.phoneNumber, user.password, [NSString stringWithFormat:@"Version: %@ (%@)", appVersionString, appBuildString], 3];
    
    [conn sendMessageWithMethodName:@"Login" soapMessage:soapMessage];
}


-(void)requestAddContactsWithDelegate:(id)delegate selector:(SEL)selector{
    MyConnection *conn = [[MyConnection alloc]init];
    conn.delegate = delegate;
    conn.selector = selector;
    
    Myuser *user = [Myuser sharedUser];
    
    NSArray *pom = [user.contactDictionary allValues];
    NSMutableArray *contactArray = [[NSMutableArray alloc]init];
    
    for (NSArray *array in pom){
        for (Contact *c in array)
            [contactArray addObject:c];
    }
    
    NSLog(@"contactArray %@", contactArray);
    
    Contact *contact = contactArray[0];
    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?> \
                             <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"> \
                             <soap:Body> \
                             <AddContacts xmlns=\"http://tempuri.org/\"> \
                             <Phonenumber>%@</Phonenumber> \
                             <password>%@</password> \
                             <ContactsPhoneNumber>%@</ContactsPhoneNumber> \
                             <Name>%@</Name> \
                             <Noter>%@</Noter> \
                             <Number>%@</Number> \
                             <URL>%@</URL> \
                             <Adress>%@</Adress> \
                             <Birthsday>%@</Birthsday> \
                             <pDate>%@</pDate> \
                             <Favorites>%d</Favorites> \
                             </AddContacts> \
                             </soap:Body> \
                             </soap:Envelope>", user.phoneNumber, user.password, contact.phoneNumber, @"", @"", @"", @"", @"", @"", @"2000-01-01T00:00:00", YES];
    
    [conn sendMessageWithMethodName:@"AddContacts" soapMessage:soapMessage];
}

-(void)requestAddMultipleContactsWithDelegate:(id)delegate selector:(SEL)selector{
    MyConnection *conn = [[MyConnection alloc]init];
    conn.delegate = delegate;
    conn.selector = selector;
    
    Myuser *user = [Myuser sharedUser];
    
    NSArray *pom = [user.contactDictionary allValues];
    NSMutableString *contactsString = [[NSMutableString alloc]init];
    
    for (NSArray *array in pom){
        for (Contact *c in array){
            [contactsString appendString:@"<csContacts>"];
            
            [contactsString appendString:[NSString stringWithFormat:@"<Phonenumber>%@</Phonenumber>", c.phoneNumber]];
            [contactsString appendString:[NSString stringWithFormat:@"<Name>%@ %@</Name>", c.firstName, c.lastName]];
            [contactsString appendString:[NSString stringWithFormat:@"<Noter>%@</Noter>", @""]];
            [contactsString appendString:[NSString stringWithFormat:@"<Number>%@</Number>", @""]];
            [contactsString appendString:[NSString stringWithFormat:@"<URL>%@</URL>", @""]];
            [contactsString appendString:[NSString stringWithFormat:@"<Adress>%@</Adress>", @""]];
            [contactsString appendString:[NSString stringWithFormat:@"<Birthsday>%@</Birthsday>", @"2000-01-01T00:00:00"]];
            [contactsString appendString:[NSString stringWithFormat:@"<pDate>%@</pDate>", @"2000-01-01T00:00:00"]];
            [contactsString appendString:[NSString stringWithFormat:@"<Favorites>%d</Favorites>", c.favorit]];
            
            [contactsString appendString:@"</csContacts>"];
        }
    }
    
   
    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?> \
                             <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"> \
                             <soap:Body> \
                             <AddMultiContacts xmlns=\"http://tempuri.org/\"> \
                             <Phonenumber>%@</Phonenumber> \
                             <password>%@</password> \
                                <Contacts> \
                                    %@ \
                                </Contacts> \
                             </AddMultiContacts> \
                             </soap:Body> \
                             </soap:Envelope>", user.phoneNumber, user.password, contactsString];
    
   //  NSLog(@"soapMessage %@", soapMessage);

    
    [conn sendMessageWithMethodName:@"AddMultiContacts" soapMessage:soapMessage];
    
}

-(void)requestCheckPhoneNumbers:(id)delegate selector:(SEL)selector{
    MyConnection *conn = [[MyConnection alloc]init];
    conn.delegate = delegate;
    conn.selector = selector;
    
    Myuser *user = [Myuser sharedUser];
    
    NSArray *pom = [user.contactDictionary allValues];
    NSMutableString *numbersString = [[NSMutableString alloc]init];
    
    for (NSArray *array in pom){
        for (Contact *c in array){
            [numbersString appendString:[NSString stringWithFormat:@"<string>%@</string>", c.phoneNumber]];
        }
    }
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?> \
                             <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"> \
                             <soap:Body> \
                             <CheckPhoneNumbers xmlns=\"http://tempuri.org/\"> \
                             <Phonenumber>%@</Phonenumber> \
                             <password>%@</password> \
                             <PhoneNumbers> \
                                %@ \
                             </PhoneNumbers> \
                             </CheckPhoneNumbers> \
                             </soap:Body> \
                             </soap:Envelope>", user.phoneNumber, user.password, numbersString];
    
      NSLog(@"soapMessage %@", soapMessage);
    
    
    [conn sendMessageWithMethodName:@"CheckPhoneNumbers" soapMessage:soapMessage];
}

@end
