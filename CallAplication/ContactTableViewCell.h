//
//  ContactTableViewCell.h
//  CallAplication
//
//  Created by David Tomic on 25/09/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface ContactTableViewCell : MGSwipeTableCell

@property (weak, nonatomic) IBOutlet UILabel *name;

@property (weak, nonatomic) IBOutlet UILabel *statusText;

@property (weak, nonatomic) IBOutlet UIButton *redStatus;
@property (weak, nonatomic) IBOutlet UIButton *yellowStatus;
@property (weak, nonatomic) IBOutlet UIButton *greenStatus;

@property (weak, nonatomic) IBOutlet UIView *statusHolderView;
@property (nonatomic, weak) IBOutlet UILabel *onPhoneLabel;

@property (nonatomic, weak) IBOutlet UIImageView *notificationImage;

@end
