//
//  FavoritesTableViewController.m
//  CallAplication
//
//  Created by David Tomic on 27/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import "DBManager.h"
#import "Myuser.h"
#import "Contact.h"
#import "FavoritTableViewCell.h"


@interface FavoritesTableViewController()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *favoritContacts;

@end

@implementation FavoritesTableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
  //  self.navigationController.navigationBar.barTintColor = [UIColor redColor];
  //  self.navigationController.navigationBar.hidden = YES;
    
  //  NSString * s = NSLocalizedString(@"TEST_STRING", @"");
 //   NSLog(@"string: %@", s);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveContactListReloadedNotification:)
                                                 name:@"ContactListReloaded"
                                               object:nil];
    
}

-(NSMutableArray *)favoritContacts{
    
    if (!_favoritContacts) _favoritContacts = [[NSMutableArray alloc]init];
    return _favoritContacts;
}

-(void)receiveContactListReloadedNotification:(NSNotification *)notification{
//    NSLog(@"receiveContactListReloadedNotification");
//    NSLog(@"COUNT %lu", (unsigned long)[Myuser sharedUser].contactDictionary.count);
    [self reloadData];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadData];
//    NSArray *tables = [[DBManager sharedInstance]getTableList];
//    NSLog(@"tables %@", tables);
}

-(void)reloadData{
    NSArray *contactArray = [[Myuser sharedUser].contactDictionary allValues];
    self.favoritContacts = nil;
    
    for (NSArray *array in contactArray){
        for (Contact *contact in array){
            if (contact.favorit) {
                [self.favoritContacts addObject:contact];
            }
        }
    }
    
    NSLog(@"favoritContacts %@", self.favoritContacts);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"COUNT %d", [self.favoritContacts count]);
    return [self.favoritContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FavoritTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
   //UITableViewCellStyleDefault FavoritTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[FavoritTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    NSLog(@"cellForRowAtIndexPath");
    
    Contact *contact = self.favoritContacts[indexPath.row];

//    UIButton *image = (UIButton *)[cell viewWithTag:1];
//    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
//    UILabel *statusTextLabel = (UILabel *)[cell viewWithTag:3];
//    
//    UIButton *status = (UIButton *)[cell viewWithTag:4];
//    UIButton *info = (UIButton *)[cell viewWithTag:5];
    
    UIImage *img2 = contact.image;
    
    if (img2.size.width > 0 && img2.size.height > 0) {
        [cell.image setImage:img2 forState:UIControlStateNormal];
        [cell.image setBackgroundColor:[UIColor clearColor]];
    }else {
        NSString *text = [[contact.firstName substringToIndex:1] uppercaseString];
        if (contact.lastName) {
            text = [NSString stringWithFormat:@"%@%@", text, [[contact.lastName substringToIndex:1] uppercaseString]];
        }
        [cell.image setBackgroundColor:[UIColor grayColor]];
        [cell.image setTitle:text forState:UIControlStateNormal];
    }
    
    NSString *text = contact.firstName;
    if (contact.lastName) {
        text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
    }
    
    cell.nameLabel.text = text;
    cell.statusTextLabel.text = @"hello this is my status";
    
    
    switch (contact.status) {
        case 0:
            [cell.status setBackgroundColor:[UIColor grayColor]];
            break;
        case 1:
            [cell.status setBackgroundColor:[UIColor redColor]];
            break;
        case 2:
            [cell.status setBackgroundColor:[UIColor yellowColor]];
            break;
        case 3:
            [cell.status setBackgroundColor:[UIColor greenColor]];
            break;
            
        default:
            [cell.status setBackgroundColor:[UIColor grayColor]];
            break;
    }
    
    [cell.info addTarget:self action:@selector(infoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"didSelectRowAtIndexPath");
    Contact *contact = self.favoritContacts[indexPath.row];
    NSString *phoneNumber = contact.phoneNumber;
    
    //NSLog(@"makeCall");
    if (phoneNumber) {
        phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet] componentsJoinedByString:@""];
        // NSLog(@"phoneNumberA %@", phoneNumber);
        
        NSString *pNumber = [@"telprompt://" stringByAppendingString:phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pNumber]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"commitEditingStyle");
    Contact *contact = self.favoritContacts[indexPath.row];
    contact.favorit = NO;
    
    NSString *phoneNumber = contact.phoneNumber;
    
    if (phoneNumber) {
        [[DBManager sharedInstance]addOrRemoveContactInFavoritWithPhoneNumber:phoneNumber];
    }
    
    [self.favoritContacts removeObjectAtIndex:indexPath.row];
    
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)infoButtonTapped:(UIButton *)button{
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        NSLog(@"index %d", indexPath.row);
    }
}

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    if(self.editing)
    {
        [super setEditing:NO animated:NO];
        [self.tableView setEditing:NO animated:NO];
        [self.tableView reloadData];
        [self.navigationItem.leftBarButtonItem setTitle:@"Edit"];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
    }
    else
    {
        [super setEditing:YES animated:YES];
        [self.tableView setEditing:YES animated:YES];
        [self.tableView reloadData];
        [self.navigationItem.leftBarButtonItem setTitle:@"Done"];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleDone];
        [self reloadData];
    }
}

@end
