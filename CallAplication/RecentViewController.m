//
//  RecentViewController.m
//  CallAplication
//
//  Created by David Tomic on 24/09/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "RecentViewController.h"
#import "DBManager.h"
#import "Myuser.h"
#import "Contact.h"
#import "ContactDetailViewController.h"
#import "RecentTableViewCell.h"
#import "MyConnectionManager.h"
#import "SharedPreferences.h"
#import "TimerNotification.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface RecentViewController ()<MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) UIImageView *redCircle;
@property (nonatomic, strong) UIImageView *yellowCircle;
@property (nonatomic, strong) UIImageView *greenCircle;

@property (nonatomic, strong) NSMutableArray *recentContacts;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//@property (nonatomic, strong) UIView *statusHolderView;
@property (weak, nonatomic) IBOutlet UIView *statusHolderView;

@property (nonatomic, strong) NSArray *notificationArray;

@end

@implementation RecentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    [self createMyStatusView];
    // Do any additional setup after loading the view.
    
    self.notificationArray = [[DBManager sharedInstance]getAllNotificationsFromDb];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveContactListReloadedNotification:)
                                                 name:@"ContactListReloaded"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveRefreshStatusNotification:)
                                                 name:@"RefreshStatus"
                                               object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshMyStatusUI];
    [self reloadData];
    
    [self.statusHolderView setFrame:CGRectMake(0, 0, self.statusHolderView.frame.size.width, self.statusHolderView.frame.size.height)];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self closeMyStatusSwipeView];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


-(void)createMyStatusView{
    
    float width = self.view.frame.size.width/3;
    float height = 50;
    
    UIPanGestureRecognizer * pan1 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveMyStatusView:)];
    pan1.minimumNumberOfTouches = 1;
    [self.statusHolderView addGestureRecognizer:pan1];
    [self.view addSubview:self.statusHolderView];
    
    UIView *redView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    UITapGestureRecognizer *redTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(redStatusTapped:)];
    [redView addGestureRecognizer:redTapRecognizer];
    [self.statusHolderView addSubview:redView];
    UIView *yellowView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(redView.frame), 0, width, height)];
    UITapGestureRecognizer *yellowTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(yellowStatusTapped:)];
    [yellowView addGestureRecognizer:yellowTapRecognizer];
    [self.statusHolderView addSubview:yellowView];
    UIView *greenView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(yellowView.frame), 0, width, height)];
    UITapGestureRecognizer *greenTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(greenStatusTapped:)];
    [greenView addGestureRecognizer:greenTapRecognizer];
    [self.statusHolderView addSubview:greenView];
    
    float ivWidth = 15;
    float ivHeight = 15;
    
    self.redCircle = [[UIImageView alloc]initWithFrame:CGRectMake(width/2-ivWidth/2, height/2-ivHeight/2, ivWidth, ivHeight)];
    self.redCircle.image = [UIImage imageNamed:@"red_circle_empty"];
    self.redCircle.highlightedImage = [UIImage imageNamed:@"red_circle_full"];
    [redView addSubview:self.redCircle];
    
    self.yellowCircle = [[UIImageView alloc]initWithFrame:CGRectMake(width/2-ivWidth/2, height/2-ivHeight/2, ivWidth, ivHeight)];
    self.yellowCircle.image = [UIImage imageNamed:@"yellow_circle_empty"];
    self.yellowCircle.highlightedImage = [UIImage imageNamed:@"yellow_circle_full"];
    [yellowView addSubview:self.yellowCircle];
    
    self.greenCircle = [[UIImageView alloc]initWithFrame:CGRectMake(width/2-ivWidth/2, height/2-ivHeight/2, ivWidth, ivHeight)];
    self.greenCircle.image = [UIImage imageNamed:@"green_circle_empty"];
    self.greenCircle.highlightedImage = [UIImage imageNamed:@"green_circle_full"];
    [greenView addSubview:self.greenCircle];
    
    [self.view layoutIfNeeded];
}
-(void)moveMyStatusView:(UIPanGestureRecognizer *)recognizer;
{
    
    CGPoint translation = [recognizer translationInView:self.view];
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    CGPoint center = recognizer.view.center;
    center.x += translation.x;
    
    if (!(center.x < 0 || center.x > recognizer.view.frame.size.width/2))
        recognizer.view.center = center;
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
       
        if (recognizer.view.frame.origin.x < -50) {
//             [UIView animateWithDuration:0.2 animations:^{
//            [recognizer.view setFrame:CGRectMake(-88, self.navigationController.toolbar.frame.size.height+20,
//                                                 recognizer.view.frame.size.width, recognizer.view.frame.size.height)];
//            }];
            [self performSegueWithIdentifier:@"Set Status Segue" sender:self];
        }else {
            
            [UIView animateWithDuration:0.2 animations:^{
            [self closeMyStatusSwipeView];
                }];
        }
    }
}
-(void)changeMyStatusTo:(Status)status{
    [Myuser sharedUser].status = status;
    [[MyConnectionManager sharedManager]requestUpdateStatusWithDelegate:self selector:@selector(responseToUpdateStatus:)];
    [TimerNotification cancelTimerNotification];
    [self refreshMyStatusUI];
}
-(void)refreshMyStatusUI{
    
    Status status = [Myuser sharedUser].status;
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *statusStartTime = [df dateFromString: [Myuser sharedUser].statusStartTime];
    NSDate *statusEndTime = [df dateFromString: [Myuser sharedUser].statusEndTime];
    
    if ([currentDate compare:statusStartTime] == NSOrderedDescending && [currentDate compare:statusEndTime] == NSOrderedAscending) {
        status = [Myuser sharedUser].timerStatus;
    }
    
    switch (status) {
        case Red_status:
            [self.redCircle setHighlighted:YES];
            [self.yellowCircle setHighlighted:NO];
            [self.greenCircle setHighlighted:NO];
            break;
        case Green_status:
            [self.redCircle setHighlighted:NO];
            [self.yellowCircle setHighlighted:NO];
            [self.greenCircle setHighlighted:YES];
            break;
        case Yellow_status:
            [self.redCircle setHighlighted:NO];
            [self.yellowCircle setHighlighted:YES];
            [self.greenCircle setHighlighted:NO];
            break;
        default:
            [self.redCircle setHighlighted:NO];
            [self.yellowCircle setHighlighted:NO];
            [self.greenCircle setHighlighted:YES];
            
            [Myuser sharedUser].status = Green_status;
            [[MyConnectionManager sharedManager]requestUpdateStatusWithDelegate:self selector:@selector(responseToUpdateStatus:)];
            
            break;
    }
}
-(void)closeMyStatusSwipeView{
    [self.statusHolderView setFrame:CGRectMake(0, 0,
                                               self.statusHolderView.frame.size.width, self.statusHolderView.frame.size.height)];
}

- (void)yellowStatusTapped:(UITapGestureRecognizer *)sender {
    [self changeMyStatusTo:Yellow_status];
}
- (void)redStatusTapped:(UITapGestureRecognizer *)sender {
    [self changeMyStatusTo:Red_status];
}
- (void)greenStatusTapped:(UITapGestureRecognizer *)sender {
    [self changeMyStatusTo:Green_status];
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
-(void)receiveRefreshStatusNotification:(NSNotification *)notification{
    // NSLog(@"receiveRefreshStatusNotification");
    [self refreshMyStatusUI];
    [self reloadData];
}

-(BOOL)hasNotification:(NSString *)phoneNumber{
    
    if (!self.notificationArray) {
        return NO;
    }else {
        for (Notification *notification in self.notificationArray){
            if ([notification.phoneNumber isEqualToString:phoneNumber]) {
                return YES;
            }
        }
    }
    
    return NO;
}

-(void)reloadData{
    NSArray *contactArray = [[Myuser sharedUser].contactDictionary allValues];
    NSArray *recentCallArray = [[DBManager sharedInstance]getAllContactDataFromRecentTable];
  //  NSLog(@"recentCallArray %@",recentCallArray);
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
            c.status = Undefined;
            [self.recentContacts addObject:c];
        }
    }
    
    self.notificationArray = [[DBManager sharedInstance]getAllNotificationsFromDb];
    
    [self.recentContacts sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
    
//    for (Contact *contact in self.recentContacts){
//        NSLog(@"recentContacts %@ time: %lld", contact.firstName, contact.timestamp);
//    }
    
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
   // NSLog(@"COUNT %lu", (unsigned long)[self.recentContacts count]);
    return [self.recentContacts count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Recent Cell"];
    
    if (cell == nil) {
        cell = [[RecentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Recent Cell"];
    }
    
    Contact *contact = self.recentContacts[indexPath.row];
    
    NSString *text = contact.firstName;
    if (contact.lastName) {
        text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
    }
    
    if (contact.recordId !=0) {
        cell.nameLabel.text = text;
    }else{
        cell.nameLabel.text = contact.phoneNumber;
    }
    cell.statusTextLabel.text = contact.statusText;
    cell.onPhoneLabel.hidden = YES;
    
    NSDateFormatter *objDateFormatter = [[NSDateFormatter alloc] init];
    [objDateFormatter setDateFormat:@"dd-MM HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:contact.timestamp/1000.0f];
    cell.dateLabel.text =[objDateFormatter stringFromDate:date];
    
    if (contact.recordId ==0) {
        cell.infoButton.hidden = YES;
    }else{
        cell.infoButton.hidden = NO;
    }
        
    BOOL hasNotification = NO;
    
    if ([self hasNotification:contact.phoneNumber])
        hasNotification = YES;
    
    if (hasNotification) {
        cell.notificationImage.hidden = NO;
    }else{
        cell.notificationImage.hidden = YES;
    }
    
    MGSwipeButton *mgSwipeButton;
    
    if (contact.status == Undefined) {
        mgSwipeButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Invite", nil) backgroundColor:[UIColor blueColor] callback:^BOOL(MGSwipeTableCell *sender) {
            NSString *phoneNumber = contact.phoneNumber;
            
            if(phoneNumber && [MFMessageComposeViewController canSendText]) {
                phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet] componentsJoinedByString:@""];
                
                MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
                controller.recipients = [NSArray arrayWithObjects:phoneNumber, nil];
                controller.messageComposeDelegate = self;
                controller.body = [Myuser sharedUser].smsInviteText;
                [self presentViewController:controller animated:YES completion:nil];
            }
            return YES;
        }];
        [cell.redStatus setSelected:NO];
        [cell.greenStatus setSelected:NO];
        [cell.yellowStatus setSelected:NO];
    }else {
        
        if (hasNotification) {
            mgSwipeButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Remove\nnotification", nil) backgroundColor:[UIColor blueColor] callback:^BOOL(MGSwipeTableCell *sender) {
                [[DBManager sharedInstance] removeNotificationFromDbWithPhoneNumber:contact.phoneNumber];
                [self reloadData];
                return YES;
            }];
        }else {
            mgSwipeButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Set\nnotification", nil) backgroundColor:[UIColor blueColor] callback:^BOOL(MGSwipeTableCell *sender) {
                [[DBManager sharedInstance] addNotificationToDbWithPhoneNumber:contact.phoneNumber name:contact.firstName status:contact.status];
                [self reloadData];
                return YES;
            }];
        }
        
        switch (contact.status) {
            case Red_status:
                [cell.redStatus setSelected:YES];
                [cell.greenStatus setSelected:NO];
                [cell.yellowStatus setSelected:NO];
                break;
            case Green_status:
                [cell.redStatus setSelected:NO];
                [cell.greenStatus setSelected:YES];
                [cell.yellowStatus setSelected:NO];
                break;
            case Yellow_status:
                [cell.redStatus setSelected:NO];
                [cell.greenStatus setSelected:NO];
                [cell.yellowStatus setSelected:YES];
                break;
            case On_phone:
                cell.statusHolderView.hidden = YES;
                cell.onPhoneLabel.hidden = NO;
                break;
            default:
                [cell.redStatus setSelected:NO];
                [cell.greenStatus setSelected:NO];
                [cell.yellowStatus setSelected:NO];
                break;
        }
    }
    
    mgSwipeButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    
    cell.rightButtons = @[mgSwipeButton];
    cell.rightSwipeSettings.transition = MGSwipeTransitionDrag;
    
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
        
        NSString *pNumber = [@"tel://" stringByAppendingString:phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pNumber]];
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.editing)
    {
        return YES;
    }else {
        return NO;
    }
}
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return UITableViewCellEditingStyleDelete;
//}

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
    if([[segue identifier]isEqualToString:@"Contact Detail Segue From Recent"]){
        if([sender isKindOfClass:[UIButton class]]){
            CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
            NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
            if(indexPath){

                if([segue.destinationViewController isKindOfClass:[ContactDetailViewController class]]){
                    
                    Contact *contact = self.recentContacts[indexPath.row];
                    ContactDetailViewController *vc = (ContactDetailViewController *)segue.destinationViewController;
                    vc.contact = contact;
                }
            }
        }
    }
}




//response methods
-(void)responseToUpdateStatus:(NSDictionary *)dict{
    NSLog(@"responseToUpdateStatus %@", dict);
    if (dict) {
        NSDictionary *pom1 = [[dict objectForKey:@"UpdateStatusResponse"] objectForKey:@"UpdateStatusResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
            [[SharedPreferences shared]saveUserData:[Myuser sharedUser]];
        }
        
    }
}

//delegate methods
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    switch(result) {
        case MessageComposeResultCancelled:
            // user canceled sms
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case MessageComposeResultSent:
            // user sent sms
            [self dismissViewControllerAnimated:YES completion:nil];
            //perhaps put an alert here and dismiss the view on one of the alerts buttons
            break;
        case MessageComposeResultFailed:
            // sms send failed
            [self dismissViewControllerAnimated:YES completion:nil];
            //perhaps put an alert here and dismiss the view when the alert is canceled
            break;
        default:
            break;
    }
}

@end
