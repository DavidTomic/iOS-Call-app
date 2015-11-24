//
//  FavoritesViewController.m
//  CallAplication
//
//  Created by David Tomic on 24/09/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "FavoritesViewController.h"
#import "MyConnectionManager.h"
#import "SharedPreferences.h"
#import "DBManager.h"
#import "Myuser.h"
#import "Contact.h"
#import "FavoritTableViewCell.h"
#import "ContactDetailViewController.h"
#import "TimerNotification.h"

@interface FavoritesViewController ()

@property (nonatomic, strong) UIImageView *redCircle;
@property (nonatomic, strong) UIImageView *yellowCircle;
@property (nonatomic, strong) UIImageView *greenCircle;

@property (nonatomic, strong) NSMutableArray *favoritContacts;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *statusHolderView;

@end

@implementation FavoritesViewController

// VC methods
- (void)viewDidLoad {
    [super viewDidLoad];
   // self.edgesForExtendedLayout=UIRectEdgeBottom;
   // self.extendedLayoutIncludesOpaqueBars=NO;
   // self.automaticallyAdjustsScrollViewInsets=NO;
    // Do any additional setup after loading the view.
    
    [self createMyStatusView];
    
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
    NSLog(@"viewWillAppear");
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self closeMyStatusSwipeView];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

//my methods
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
   // NSLog(@"moveMyStatusView");
    
    CGPoint translation = [recognizer translationInView:self.view];
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    CGPoint center = recognizer.view.center;
    center.x += translation.x;
    
  //  NSLog(@"center x %f", center.x);
    
    if (!(center.x < 0 || center.x > recognizer.view.frame.size.width/2))
        recognizer.view.center = center;
    
  //  NSLog(@"recognizer.view.frame.origin.x %f", recognizer.view.frame.origin.x);
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
    //    NSLog(@"UIGestureRecognizerStateEnded");
        
        if (recognizer.view.frame.origin.x < -50) {
            
//            [UIView animateWithDuration:0.2 animations:^{
//                
//                [recognizer.view setFrame:CGRectMake(-88, self.navigationController.toolbar.frame.size.height+20,
//                                                     recognizer.view.frame.size.width, recognizer.view.frame.size.height)];
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
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
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
    [self.statusHolderView setFrame:CGRectMake(0, self.navigationController.toolbar.frame.size.height+20,
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

-(NSMutableArray *)favoritContacts{
    
    if (!_favoritContacts) _favoritContacts = [[NSMutableArray alloc]init];
    return _favoritContacts;
}

-(void)receiveContactListReloadedNotification:(NSNotification *)notification{
    [self reloadData];
    
}
-(void)receiveRefreshStatusNotification:(NSNotification *)notification{
    NSLog(@"receiveRefreshStatusNotification");
    [self refreshMyStatusUI];
    [self reloadData];
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
    
    // NSLog(@"favoritContacts %@", self.favoritContacts);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
-(void)statusTapped:(UITapGestureRecognizer *)tapRecognizer{
    NSLog(@"status tapped");
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
    // NSLog(@"COUNT %d", [self.favoritContacts count]);
    return [self.favoritContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FavoritTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[FavoritTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    Contact *contact = self.favoritContacts[indexPath.row];
    
    UIImage *img2 = contact.image;
    
    if (img2.size.width > 0 && img2.size.height > 0) {
        [cell.image setImage:img2 forState:UIControlStateNormal];
        [cell.image setBackgroundColor:[UIColor clearColor]];
    }else {
        [cell.image setImage:nil forState:UIControlStateNormal];
        NSString *text = [[contact.firstName substringToIndex:1] uppercaseString];
        if (contact.lastName) {
            text = [NSString stringWithFormat:@"%@%@", text, [[contact.lastName substringToIndex:1] uppercaseString]];
        }
        [cell.image setBackgroundColor:self.view.tintColor];
        [cell.image setTitle:text forState:UIControlStateNormal];
    }
    
    NSString *text = contact.firstName;
    if (contact.lastName) {
        text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
    }
    
    cell.nameLabel.text = text;
    cell.statusTextLabel.text = contact.statusText;
    
    cell.onPhoneLabel.hidden = YES;
    cell.statusHolderView.hidden = NO;
    
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
    
    //    [cell.info addTarget:self action:@selector(infoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
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
        
        NSLog(@"contact.recordId %d", contact.recordId);
        
        [Myuser sharedUser].lastDialedRecordId = contact.recordId;
        
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
    
    [[DBManager sharedInstance]addOrRemoveContactInFavoritWithRecordId:contact.recordId];
    
    
    [self.favoritContacts removeObjectAtIndex:indexPath.row];
    
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    if(self.editing)
    {
        [super setEditing:NO animated:NO];
        [self.tableView setEditing:NO animated:NO];
        [self.tableView reloadData];
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Edit", nil)];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
    }
    else
    {
        [super setEditing:YES animated:YES];
        [self.tableView setEditing:YES animated:YES];
        [self.tableView reloadData];
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Done", nil)];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
        [self reloadData];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier]isEqualToString:@"Contact Detail Segue From Favorites"]){
        if([sender isKindOfClass:[UIButton class]]){
            CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
            NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
            if(indexPath){
                if([segue.destinationViewController isKindOfClass:[ContactDetailViewController class]]){
                    Contact *contact = self.favoritContacts[indexPath.row];
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


@end
