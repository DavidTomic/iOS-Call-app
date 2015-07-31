//
//  MyConnection.h
//  CallAplication
//
//  Created by David Tomic on 30/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyConnection : NSObject


@property (nonatomic, strong) id delegate;
@property (nonatomic, assign) SEL selector;
- (void)sendMessageWithMethodName:(NSString *)methodName soapMessage:(NSString *)soapMessage;

@end
