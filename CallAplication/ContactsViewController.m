//
//  ContactsTableViewController.m
//  CallAplication
//
//  Created by David Tomic on 27/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "ContactsViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Contact.h"
#import "ContactDetailViewController.h"
#import "Myuser.h"
#import "ContactTableViewCell.h"
#import "TabBarViewController.h"
#import "SharedPreferences.h"
#import "MyConnectionManager.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "TimerNotification.h"

#import <malloc/malloc.h>
#import <objc/runtime.h>

@interface ContactsViewController()<UITableViewDataSource, UITableViewDelegate, ABNewPersonViewControllerDelegate,
UISearchBarDelegate, UISearchDisplayDelegate, MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic) ABAddressBookRef addressBook;
@property (nonatomic, strong) Myuser * myUser;

@property (strong,nonatomic) NSMutableArray *filteredContactArray;
@property (nonatomic, strong) UIImageView *redCircle;
@property (nonatomic, strong) UIImageView *yellowCircle;
@property (nonatomic, strong) UIImageView *greenCircle;

@property (weak, nonatomic) IBOutlet UIView *statusHolderView;

@end

@implementation ContactsViewController

//viewController methods
-(void)viewDidLoad{
    [super viewDidLoad];
    
//    self.edgesForExtendedLayout=UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars=NO;
//    self.automaticallyAdjustsScrollViewInsets=NO;
    
    self.myUser = [Myuser sharedUser];
    [self createMyStatusView];
    
    self.filteredContactArray = [[NSMutableArray alloc]init];
   // self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithRed:55/255.0f green:60/255.0f blue:65/255.0f alpha:1.0f];
    [self.searchDisplayController.searchResultsTableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:@"ContactCell"];
    [self.searchDisplayController.searchResultsTableView setRowHeight:self.tableView.rowHeight];


    CFErrorRef * error = NULL;
    self.addressBook = ABAddressBookCreateWithOptions(NULL, error);
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveContactListReloadedNotification:)
                                                 name:@"ContactListReloaded"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveRefreshStatusNotification:)
                                                 name:@"RefreshStatus"
                                               object:nil];
    
}
-(void)receiveContactListReloadedNotification:(NSNotification *)notification{
    NSLog(@"receiveContactListReloadedNotification");
    [self reloadData];
}
-(void)receiveRefreshStatusNotification:(NSNotification *)notification{
   // NSLog(@"receiveRefreshStatusNotification");
    [self refreshMyStatusUI];
    [self reloadData];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  //  NSLog(@"prepareForSegue");
    if([sender isKindOfClass:[UITableView class]]){
        NSIndexPath *indexPath = [sender indexPathForSelectedRow];
        if(indexPath){
            if([[segue identifier]isEqualToString:@"Contact Detail Segue"]){
                if([segue.destinationViewController isKindOfClass:[ContactDetailViewController class]]){
   
                    Contact *person = nil;
                    if (sender == self.searchDisplayController.searchResultsTableView) {
                        person = self.filteredContactArray[indexPath.row];
                    }else{
                        NSArray *keys = [self.myUser.contactDictionary allKeys];
                        keys = [keys sortedArrayUsingComparator:^(id a, id b) {
                            return [a compare:b options:NSNumericSearch];
                        }];
                        
                        NSString *key = keys[indexPath.section];
                        person = [self.myUser.contactDictionary objectForKey:key][indexPath.row];
                    }

                    NSLog(@"firstName %@", person.firstName);
                    NSLog(@"recordId %d", person.recordId);
                    
                    ContactDetailViewController *vc = (ContactDetailViewController *)segue.destinationViewController;
                    vc.contact = person;
                }
            }
        }
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self closeMyStatusSwipeView];
    self.tableView.editing=NO;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"CT viewWillAppear");
    
    CGRect frame = self.tableView.tableHeaderView.frame;
    frame.size.height = 44;
    UILabel *headerView = [[UILabel alloc] initWithFrame:frame];
    [headerView setText:[NSString stringWithFormat:@"   %@: %@", NSLocalizedString(@"My number", nil), [Myuser sharedUser].phoneNumber]];
    [self.tableView setTableHeaderView:headerView];
    
    [self refreshMyStatusUI];
}


//my methods
-(void)createMyStatusView{
    
    float width = self.view.frame.size.width/3;
    float height = 40;
    
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
//            [UIView animateWithDuration:0.2 animations:^{
//            [recognizer.view setFrame:CGRectMake(-88, 108,
//                                                 recognizer.view.frame.size.width, recognizer.view.frame.size.height)];
//                 }];
            [self performSegueWithIdentifier:@"Set Status Segue" sender:self];
        }else {
           [UIView animateWithDuration:0.2 animations:^{
            
             [self closeMyStatusSwipeView];
                }];
        }
    }
}
-(void)closeMyStatusSwipeView{
    [self.statusHolderView setFrame:CGRectMake(0, 108,
                                         self.statusHolderView.frame.size.width, self.statusHolderView.frame.size.height)];
}

-(void)reloadData{

 //   self.data = [[NSMutableDictionary alloc] initWithDictionary:self.myUser.contactDictionary copyItems:YES];
    self.data = [self.myUser.contactDictionary copy];
    
//    NSLog(@"1Size of %@: %zd", NSStringFromClass([NSDictionary class]), malloc_size((__bridge const void *) self.data));
//    NSLog(@"2Size of %@: %zd", NSStringFromClass([NSDictionary class]), malloc_size((__bridge const void *) self.myUser.contactDictionary));
//    
//    NSLog(@"self.data: %lu", (uintptr_t)self.data);
//    NSLog(@"self.myUser.contactDictionary: %lu", (uintptr_t)self.myUser.contactDictionary);
    
    [self.tableView reloadData];
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
-(void)changeMyStatusTo:(Status)status{
    [Myuser sharedUser].status = status;
    [[MyConnectionManager sharedManager]requestUpdateStatusWithDelegate:self selector:@selector(responseToUpdateStatus:)];
    [TimerNotification cancelTimerNotification];
    [self refreshMyStatusUI];
}

//IBAction methods
- (IBAction)addContactPressed:(UIBarButtonItem *)sender {
    ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
    picker.newPersonViewDelegate = self;
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
    [self presentViewController:navigation animated:YES completion:nil];
    
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
#pragma mark UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger count = 0;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
   
            count = 1;
        
    } else {
        count = [[self.data allKeys] count];
    }
    
  //  NSLog(@"return %d", count);
    
    return count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    float height = 25;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, height)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, height, height)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    [label setTextColor:[UIColor whiteColor]];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = self.view.tintColor;
    label.layer.cornerRadius = label.frame.size.width / 2;
    label.layer.borderWidth = 0;
    label.clipsToBounds = YES;
    
    NSString *string =@"";
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (self.filteredContactArray.count == 0) {
            return nil;
        }
        string = [[((Contact *)self.filteredContactArray[0]).firstName substringToIndex:1] uppercaseString];
    } else {
        NSArray *keys = [self.data allKeys];
        keys = [keys sortedArrayUsingComparator:^(id a, id b) {
            return [a compare:b options:NSNumericSearch];
        }];
        string = keys[section];
    }
    
    
    
    /* Section header is in 0th index... */
    [label setText:string];
    
    
    [view addSubview:label];
    [view setBackgroundColor:[UIColor whiteColor]]; //your background color...
    return view;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
             if (self.filteredContactArray.count == 0) {
                 return nil;
             }
        return [[((Contact *)self.filteredContactArray[0]).firstName substringToIndex:1] uppercaseString];
    } else {
        NSArray *keys = [self.data allKeys];
        keys = [keys sortedArrayUsingComparator:^(id a, id b) {
            return [a compare:b options:NSNumericSearch];
        }];
        return keys[section];
    }
    

}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        NSArray *keys = [self.data allKeys];
      //  NSArray * keys = @[@"A", @"B", @"C", @"D", @"H", @"E", @"T", @"R", @"I", @"M", @"Z"];
        keys = [keys sortedArrayUsingComparator:^(id a, id b) {
            return [a compare:b options:NSNumericSearch];
        }];
        return keys;
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.filteredContactArray.count;
    } else {
        NSArray *keys = [self.data allKeys];
        keys = [keys sortedArrayUsingComparator:^(id a, id b) {
            return [a compare:b options:NSNumericSearch];
        }];
        
        NSString *key = keys[section];
        return [[self.data objectForKey:key] count];
    }
    

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    
    if (cell == nil) {
        cell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactCell"];
    }
    

    Contact *contact = nil;
    NSString *key = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
      //  NSLog(@"COUNT %d", self.filteredContactArray.count);
        contact = [self.filteredContactArray objectAtIndex:indexPath.row];
        
        cell.backgroundColor = [UIColor clearColor];
    } else {
        NSArray *keys = [self.data allKeys];
        keys = [keys sortedArrayUsingComparator:^(id a, id b) {
            return [a compare:b options:NSNumericSearch];
        }];
        key = keys[indexPath.section];
        
        contact = [self.data objectForKey:key][indexPath.row];
        
    }
    
    NSString *text = contact.firstName;
    if (contact.lastName) {
        text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
    }
    // [cell.textLabel setTextColor:[UIColor colorWithRed:242/255.0f green:242/255.0f blue:242/255.0f alpha:1.0f]];
    cell.name.text = text;
    cell.statusText.text = contact.statusText;

    
    cell.onPhoneLabel.hidden = YES;
    cell.statusHolderView.hidden = NO;
    
    NSLog(@"status %d", contact.status);
    
    MGSwipeButton *deleteButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Delete", nil) backgroundColor:[UIColor lightGrayColor] callback:^BOOL(MGSwipeTableCell *sender) {
        NSLog(@"Convenience callback for swipe buttons!");
        
        ABRecordRef person = ABAddressBookGetPersonWithRecordID(self.addressBook, contact.recordId);
        if (person) {
            
            CFErrorRef *error = NULL;
            ABAddressBookRemoveRecord(self.addressBook, person, error);
            ABAddressBookSave(self.addressBook, error);
            
            NSMutableArray *pom = [self.data objectForKey:key];
            [pom removeObject:contact];
            [self reloadData];
            [((TabBarViewController *)self.tabBarController) checkAndUpdateAllContact];
            
            [[MyConnectionManager sharedManager]requestDeleteContactWithPhoneNumberToDelete:contact.phoneNumber delegate:self selector:nil];
        }
        
        return YES;
    }];
    MGSwipeButton *secondButton;
    
    if (contact.status == Undefined) {
        secondButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Invite", nil) backgroundColor:[UIColor blueColor]callback:^BOOL(MGSwipeTableCell *sender) {
                    NSString *phoneNumber = contact.phoneNumber;
            
                    if(phoneNumber && [MFMessageComposeViewController canSendText]) {
                        phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet] componentsJoinedByString:@""];
            
                        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
                        controller.recipients = [NSArray arrayWithObjects:phoneNumber, nil];
                        controller.messageComposeDelegate = self;
                        [self presentViewController:controller animated:YES completion:nil];
                    }
            return YES;
        }];
        [cell.redStatus setSelected:NO];
        [cell.greenStatus setSelected:NO];
        [cell.yellowStatus setSelected:NO];
    }else {
        secondButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Set notification", nil) backgroundColor:[UIColor blueColor]];
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
    
    cell.rightButtons = @[deleteButton,secondButton];
    cell.rightSwipeSettings.transition = MGSwipeTransitionDrag;

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Contact Detail Segue" sender:tableView];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //NSLog(@"didSelectRowAtIndexPath");
    
}

//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"commitEditingStyle");
//  //  [tableView deselectRowAtIndexPath:indexPath animated:YES];
//   
//    Contact *contact = nil;
//    if (tableView == self.searchDisplayController.searchResultsTableView) {
//        contact = self.filteredContactArray[indexPath.row];
//    }else{
//        NSArray *keys = [self.myUser.contactDictionary allKeys];
//        keys = [keys sortedArrayUsingComparator:^(id a, id b) {
//            return [a compare:b options:NSNumericSearch];
//        }];
//        
//        NSString *key = keys[indexPath.section];
//        contact = [self.myUser.contactDictionary objectForKey:key][indexPath.row];
//    }
//    
//    
//    NSArray *mcheckPhoneNumberArray = [Myuser sharedUser].checkPhoneNumberArray;
//    
//    if ([mcheckPhoneNumberArray containsObject:contact.phoneNumber]) {
//        
//    }else {
//        NSString *phoneNumber = contact.phoneNumber;
//        
//        if(phoneNumber && [MFMessageComposeViewController canSendText]) {
//            phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet] componentsJoinedByString:@""];
//            
//            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
//            controller.recipients = [NSArray arrayWithObjects:phoneNumber, nil];
//            controller.messageComposeDelegate = self;
//            [self presentViewController:controller animated:YES completion:nil];
//        }
//    }
//
//    self.tableView.editing=NO;
//    
//}




#pragma mark ABNewPersonViewControllerDelegate methods
// Dismisses the new-person view controller.
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
    
    if (person != nil)  //nil = Cancel button clicked
    {
        NSLog(@"person %@", person);
        [(TabBarViewController *)self.tabBarController checkAndUpdateAllContact];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredContactArray removeAllObjects];
    // Filter the array using NSPredicate
  //  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.firstName BEGINSWITH[c] %@", searchText];
    
    
    BOOL isDigit;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:searchText];
    isDigit = [alphaNums isSupersetOfSet:inStringSet];
    
    NSPredicate *predicate;
    if (isDigit) {
        predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"SELF.phoneNumber MATCHES '.*%@.*'", searchText]];
    }else {
        predicate = [NSPredicate predicateWithFormat:@"SELF.firstName BEGINSWITH[c] %@", searchText];
    }
    
    NSMutableArray *pomArray = [NSMutableArray array];
    NSArray *pom = [self.data allValues];
    
    for (NSArray *array in pom) {
        for (Contact *c in array){
            [pomArray addObject:c];
        }
    }
    
    self.filteredContactArray = [NSMutableArray arrayWithArray:[pomArray filteredArrayUsingPredicate:predicate]];
    
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

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
