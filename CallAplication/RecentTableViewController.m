//
//  CallListTableViewController.m
//  CallAplication
//
//  Created by David Tomic on 27/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "RecentTableViewController.h"
#import "DBManager.h"
#import "Myuser.h"
#import "Contact.h"
#import "FavoritTableViewCell.h"
#import "ContactDetailViewController.h"


@interface RecentTableViewController()

@property (nonatomic, strong) NSMutableArray *recentContacts;

@end

@implementation RecentTableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveContactListReloadedNotification:)
                                                 name:@"ContactListReloaded"
                                               object:nil];
}
-(NSMutableArray *)recentContacts{
    
    if (!_recentContacts) _recentContacts = [[NSMutableArray alloc]init];
    return _recentContacts;
}
-(void)receiveContactListReloadedNotification:(NSNotification *)notification{
    //    NSLog(@"receiveContactListReloadedNotification");
    //    NSLog(@"COUNT %lu", (unsigned long)[Myuser sharedUser].contactDictionary.count);
    [self reloadData];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadData];
}

-(void)reloadData{
    NSArray *contactArray = [[Myuser sharedUser].contactDictionary allValues];
    NSArray *recentCallArray = [[DBManager sharedInstance]getAllContactDataFromRecentTable];
    self.recentContacts = nil;
    
    for (NSArray *pomArray1 in contactArray){
        for (Contact *contact in pomArray1){
            for(NSArray *pomArray2 in recentCallArray){
                if (contact.recordId == [pomArray2[0] integerValue]) {
                    contact.timestamp = [pomArray2[2]longLongValue];
                    [self.recentContacts addObject:contact];
                }
            }

        }
    }
    
    for (Contact *contact in self.recentContacts){
        NSLog(@"recentContacts %@ time: %lld", contact.firstName, contact.timestamp);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


@end
