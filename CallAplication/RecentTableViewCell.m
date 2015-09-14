//
//  RecentTableViewCell.m
//  CallAplication
//
//  Created by David Tomic on 08/08/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "RecentTableViewCell.h"

@implementation RecentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    UIView * selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:[UIColor colorWithWhite:220/255.0f alpha:0.2f]]; // set color here
    [self setSelectedBackgroundView:selectedBackgroundView];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self layoutIfNeeded];
}

-(void)layoutIfNeeded{
    [super layoutIfNeeded];
    //  NSLog(@"W %f",self.image.frame.size.width);
}

@end
