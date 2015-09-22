//
//  Person.m
//  CallAplication
//
//  Created by David Tomic on 03/08/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "Contact.h"

@implementation Contact

-(id)copyWithZone:(NSZone *)zone{
    
    Contact *c = [[Contact allocWithZone:zone]init];
    c.phoneNumber = self.phoneNumber;
    c.firstName = self.firstName;
    c.lastName = self.lastName;
    c.recordId = self.recordId;
    c.favorit = self.favorit;
    c.image = self.image;
    c.timestamp = self.timestamp;
    c.status = self.status;
    c.statusText = self.statusText;
  //  c.endTime = self.endTime;
    return c;
}

@end
