//
//  SettingsDetailViewController.h
//  CallAplication
//
//  Created by David Tomic on 25/09/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsDetailViewController : UIViewController

@property (strong, nonatomic) NSString *item;

@property (nonatomic) BOOL editDefaultText;
@property (nonatomic) NSInteger textId;

@end
