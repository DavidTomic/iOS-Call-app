//
//  MyStatus.h
//  CallAplication
//
//  Created by David Tomic on 22/09/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyStatus : NSObject

typedef NS_ENUM(NSUInteger, Status) {
    Red_status = 0,
    Green_status = 1,
    Yellow_status = 2,
    On_phone = 3,
    Undefined = 9
};

@end
