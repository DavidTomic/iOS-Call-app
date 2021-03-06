//
//  Person.h
//  CallAplication
//
//  Created by David Tomic on 03/08/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MyStatus.h"

@interface Contact : NSObject<NSCopying>

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic) int recordId;
@property (nonatomic) BOOL favorit;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) long long timestamp;

@property (nonatomic) Status status;
@property (nonatomic, strong) NSString *statusText;
//@property (nonatomic, strong) NSString *endTime;

-(id)copyWithZone:(NSZone *)zone;

@end
