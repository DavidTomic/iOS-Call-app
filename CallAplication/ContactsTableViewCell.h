//
//  ContactsTableViewCell.h
//  CallAplication
//
//  Created by David Tomic on 08/08/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *statusText;

@property (weak, nonatomic) IBOutlet UIButton *statusRed;
@property (weak, nonatomic) IBOutlet UIButton *statusYellow;
@property (weak, nonatomic) IBOutlet UIButton *statusGreen;

@end
