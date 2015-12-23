//
//  MyConnection.m
//  CallAplication
//
//  Created by David Tomic on 30/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "MyConnection.h"
#import "NSDictionary+XMLDictionary.h"

@interface MyConnection() <NSURLConnectionDelegate>
{
    NSMutableData *_receivedData;
    long statusCode;
}

@end


NSString *const urlString = @"https://ws.when2call.dk/wscall.asmx";

@implementation MyConnection

- (void)sendMessageWithMethodName:(NSString *)methodName soapMessage:(NSString *)soapMessage
{
    NSLog(@"sendMessageWithMethodName %@", methodName);
    
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    NSURL *pomUrl = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:pomUrl
                                            cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0f];
    request.HTTPMethod = @"POST";
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue: [NSString stringWithFormat:@"http://tempuri.org/%@", methodName] forHTTPHeaderField:@"SOAPAction"];
    [request setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection =[[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    if(connection)
        _receivedData = [[NSMutableData alloc] init];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSString *myString = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"mystring %@", myString);
    NSDictionary *parsedObject = [[NSDictionary dictionaryWithXMLString:myString] objectForKey:@"soap:Body"];
   // NSLog(@"response %@", parsedObject);

    
    if (parsedObject) {
        if ([parsedObject objectForKey:@"soap:Fault"]) {
            parsedObject = nil;
        }
    }
    
    if(self.delegate && [self.delegate respondsToSelector:self.selector])
    {
        
            ((void (*)(id, SEL, NSDictionary *))[self.delegate methodForSelector:self.selector])(self.delegate, self.selector, parsedObject);
    }
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    statusCode = [httpResponse statusCode];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    if(self.delegate && [self.delegate respondsToSelector:self.selector])
    {
        ((void (*)(id, SEL, NSDictionary *))[self.delegate methodForSelector:self.selector])(self.delegate, self.selector, nil);
    }
}

@end
