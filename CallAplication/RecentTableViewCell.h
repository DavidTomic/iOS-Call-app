//
//  RecentTableViewCell.h
//  CallAplication
//
//  Created by David Tomic on 08/08/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;


@property (weak, nonatomic) IBOutlet UILabel *statusTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceDateLabelConstraint;

@property (weak, nonatomic) IBOutlet UIButton *redStatus;
@property (weak, nonatomic) IBOutlet UIButton *yellowStatus;
@property (weak, nonatomic) IBOutlet UIButton *greenStatus;

@property (weak, nonatomic) IBOutlet UIView *statusHolderView;
@property (nonatomic, weak) IBOutlet UILabel *onPhoneLabel;

@end
