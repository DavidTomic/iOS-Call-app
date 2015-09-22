//
//  TabBarViewController.h
//  CallAplication
//
//  Created by David Tomic on 31/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabBarViewController : UITabBarController

@property (nonatomic) BOOL cameFromRegistration;

-(void)refreshCheckPhoneNumbers;
-(void)checkAndUpdateAllContact;
@end
