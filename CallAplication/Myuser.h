//
//  Myuser.h
//  CallAplication
//
//  Created by David Tomic on 31/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Myuser : NSObject

+(Myuser *) sharedUser;

@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *defaultText;
@property (nonatomic) BOOL logedIn;

@end
