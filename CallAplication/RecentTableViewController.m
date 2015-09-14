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
#import "ContactDetailViewController.h"
#import "RecentTableViewCell.h"


@interface RecentTableViewController()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *recentContacts;
@property (nonatomic, strong) UIView *navView;


@end

@implementation RecentTableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
//    float navViewHeight = 43;
//    self.navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, navViewHeight)];
//    
//    UIView *circle = [[UIView alloc]initWithFrame:CGRectMake(10, navViewHeight/2-5, 10, 10)];
//    circle.backgroundColor = [UIColor greenColor];
//    circle.layer.cornerRadius = circle.frame.size.width / 2;
//    circle.layer.borderWidth = 0;
//    circle.clipsToBounds = YES;
//    [self.navView addSubview:circle];
//    
//    UILabel *statusLabel = [[UILabel alloc]init];
//    statusLabel.text = @"This is my status..";
//    statusLabel.textColor = [UIColor lightGrayColor];
//    [statusLabel setFont:[statusLabel.font fontWithSize:10]];
//    [statusLabel sizeToFit];
//    statusLabel.frame = CGRectMake(10, navViewHeight-statusLabel.frame.size.height-2, statusLabel.frame.size.width, statusLabel.frame.size.height);
//    [self.navView addSubview:statusLabel];
//    
//    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(statusTapped:)];
//    [self.navView addGestureRecognizer:tapRecognizer];
//    
//    [self.navigationController.navigationBar addSubview:self.navView];
    
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
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navView.hidden = YES;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navView.hidden = NO;
}
-(void)statusTapped:(UITapGestureRecognizer *)tapRecognizer{
    NSLog(@"status tapped");
}

-(void)reloadData{
    NSArray *contactArray = [[Myuser sharedUser].contactDictionary allValues];
    NSArray *recentCallArray = [[DBManager sharedInstance]getAllContactDataFromRecentTable];
    NSLog(@"recentCallArray %@",recentCallArray);
    self.recentContacts = nil;
    
    for (NSArray *pomArray1 in contactArray){
        for (Contact *contact in pomArray1){
            for(NSArray *pomArray2 in recentCallArray){
                if (contact.recordId == [pomArray2[0] integerValue]) {
                    Contact *c = [contact copy];
                    c.timestamp = [pomArray2[2]longLongValue];
                    [self.recentContacts addObject:c];
                }
            }

        }
    }
    
    for(NSArray *pomArray2 in recentCallArray){
        if ([pomArray2[0] integerValue] == 0){
            Contact *c = [Contact new];
            c.phoneNumber = pomArray2[1];
            c.timestamp = [pomArray2[2]longLongValue];
            [self.recentContacts addObject:c];
        }
    }
    
    [self.recentContacts sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]]];
    
    for (Contact *contact in self.recentContacts){
        NSLog(@"recentContacts %@ time: %lld", contact.firstName, contact.timestamp);
    }
    
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
   // NSLog(@"COUNT %d", [self.recentContacts count]);
    return [self.recentContacts count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecentCell"];
    
    if (cell == nil) {
        cell = [[RecentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RecentCell"];
    }
    
    Contact *contact = self.recentContacts[indexPath.row];
    
    
    if (contact.recordId !=0) {
        cell.infoButton.hidden = NO;
       // cell.status.hidden = NO;
        cell.topSpaceDateLabelConstraint.constant = 11;
    }else{
        cell.infoButton.hidden = YES;
      //  cell.status.hidden = YES;
        cell.topSpaceDateLabelConstraint.constant = -3;
    }
    
    
    NSString *text = contact.firstName;
    if (contact.lastName) {
        text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
    }
    
    if (contact.recordId !=0) {
        cell.nameLabel.text = text;
    }else{
        cell.nameLabel.text = contact.phoneNumber;
    }
    cell.statusTextLabel.text = @"hello this is my status";
    NSDateFormatter *objDateFormatter = [[NSDateFormatter alloc] init];
    [objDateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:contact.timestamp/1000.0f];
    cell.dateLabel.text =[objDateFormatter stringFromDate:date];
    
//    switch (contact.status) {
//        case 0:
//            [cell.status setBackgroundColor:[UIColor grayColor]];
//            break;
//        case 1:
//            [cell.status setBackgroundColor:[UIColor redColor]];
//            break;
//        case 2:
//            [cell.status setBackgroundColor:[UIColor yellowColor]];
//            break;
//        case 3:
//            [cell.status setBackgroundColor:[UIColor greenColor]];
//            break;
//            
//        default:
//            [cell.status setBackgroundColor:[UIColor grayColor]];
//            break;
//    }
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"didSelectRowAtIndexPath");
    Contact *contact = self.recentContacts[indexPath.row];
    NSString *phoneNumber = contact.phoneNumber;
    
    //NSLog(@"makeCall");
    if (phoneNumber) {
        phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet] componentsJoinedByString:@""];
        // NSLog(@"phoneNumberA %@", phoneNumber);
        
        if (contact.recordId != 0) {
            [Myuser sharedUser].lastDialedRecordId = contact.recordId;
        }else{
            [Myuser sharedUser].lastDialedPhoneNumber = contact.phoneNumber;
        }
        
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
    Contact *contact = self.recentContacts[indexPath.row];
    
    if (contact.recordId != 0) {
        NSLog(@"delete 1");
        [[DBManager sharedInstance]deleteContactFromRecentWithRecordId:contact.recordId phoneNumber:nil timestamp:contact.timestamp];
    }else{
        NSLog(@"delete 2");
        [[DBManager sharedInstance]deleteContactFromRecentWithRecordId:0 phoneNumber:contact.phoneNumber timestamp:contact.timestamp];
    }
    
    [self.recentContacts removeObjectAtIndex:indexPath.row];
    
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    if(self.editing)
    {
        [super setEditing:NO animated:NO];
        [self.tableView setEditing:NO animated:NO];
        [self.tableView reloadData];
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
    }
    else
    {
        [super setEditing:YES animated:YES];
        [self.tableView setEditing:YES animated:YES];
        [self.tableView reloadData];
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
     //   [self reloadData];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([sender isKindOfClass:[UIButton class]]){
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        if(indexPath){
            if([[segue identifier]isEqualToString:@"Contact Detail Segue From Recent"]){
                if([segue.destinationViewController isKindOfClass:[ContactDetailViewController class]]){
                    
                    Contact *contact = self.recentContacts[indexPath.row];
                    ContactDetailViewController *vc = (ContactDetailViewController *)segue.destinationViewController;
                    vc.contact = contact;
                }
            }
        }
    }
}


@end
