//
//  Notification.h
//  CallAplication
//
//  Created by David Tomic on 01/12/15.
//  Copyright © 2015 David Tomic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyStatus.h"

@interface Notification : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic) Status status;

@end
