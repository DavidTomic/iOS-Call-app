//
//  ContactDetailViewController.h
//  CallAplication
//
//  Created by David Tomic on 06/08/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ContactsViewController.h"

@interface ContactDetailViewController : UIViewController

@property (nonatomic) ABRecordRef people;

@end
