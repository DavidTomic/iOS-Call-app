//
//  FavoritTableViewCell.h
//  CallAplication
//
//  Created by David Tomic on 07/08/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoritTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *image;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *info;
@property (weak, nonatomic) IBOutlet UIButton *redStatus;
@property (weak, nonatomic) IBOutlet UIButton *yellowStatus;
@property (weak, nonatomic) IBOutlet UIButton *greenStatus;

@property (weak, nonatomic) IBOutlet UIView *statusHolderView;
@property (nonatomic, weak) IBOutlet UILabel *onPhoneLabel;

@end
