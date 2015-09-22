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
#import "ContactsTableViewCell.h"
#import "TabBarViewController.h"
#import "SharedPreferences.h"
#import "MyConnectionManager.h"

@interface ContactsViewController()<UITableViewDataSource, UITableViewDelegate, ABNewPersonViewControllerDelegate,UISearchBarDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic) ABAddressBookRef addressBook;
@property (nonatomic, strong) Myuser * myUser;
@property (nonatomic, strong) UIView *navView;

@property (strong,nonatomic) NSMutableArray *filteredContactArray;
@property (weak, nonatomic) IBOutlet UIImageView *redCircle;
@property (weak, nonatomic) IBOutlet UIImageView *yellowCircle;
@property (weak, nonatomic) IBOutlet UIImageView *greenCircle;

@end

@implementation ContactsViewController

//viewController methods
-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.myUser = [Myuser sharedUser];
    
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
    
    self.filteredContactArray = [[NSMutableArray alloc]init];
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithRed:55/255.0f green:60/255.0f blue:65/255.0f alpha:1.0f];
    [self.searchDisplayController.searchResultsTableView registerClass:[ContactsTableViewCell class] forCellReuseIdentifier:@"ContactCell"];
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
   // NSLog(@"receiveContactListReloadedNotification");
    [self reloadData];
}
-(void)receiveRefreshStatusNotification:(NSNotification *)notification{
   // NSLog(@"receiveRefreshStatusNotification");
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
    self.navView.hidden = YES;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navView.hidden = NO;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    CGRect frame = self.tableView.tableHeaderView.frame;
    frame.size.height = 44;
    UILabel *headerView = [[UILabel alloc] initWithFrame:frame];
    [headerView setText:[NSString stringWithFormat:@"   %@: %@", NSLocalizedString(@"My number", nil), [Myuser sharedUser].phoneNumber]];
    [self.tableView setTableHeaderView:headerView];
    
    [self refreshMyStatusUI];
}

//my methods
-(void)reloadData{
    NSLog(@"relaodData %lu", (unsigned long)self.myUser.contactDictionary.count);
    
    self.data = [self.myUser.contactDictionary copy];
    
    [self.tableView reloadData];
}
-(void)refreshMyStatusUI{

    [self setMyStatusCircles];
}
-(void)setMyStatusCircles{
    
    Status status = [Myuser sharedUser].status;
    
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
    [self setMyStatusCircles];
}

//IBAction methods
- (IBAction)addContactPressed:(UIBarButtonItem *)sender {
    ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
    picker.newPersonViewDelegate = self;
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
    [self presentViewController:navigation animated:YES completion:nil];
    
}
- (IBAction)yellowStatusTapped:(UITapGestureRecognizer *)sender {
    [self changeMyStatusTo:Yellow_status];
}
- (IBAction)redStatusTapped:(UITapGestureRecognizer *)sender {
    [self changeMyStatusTo:Red_status];
}
- (IBAction)greenStatusTapped:(UITapGestureRecognizer *)sender {
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
    
    ContactsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    
    if (cell == nil) {
        cell = [[ContactsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactCell"];
    }
    

    Contact *contact = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
      //  NSLog(@"COUNT %d", self.filteredContactArray.count);
        contact = [self.filteredContactArray objectAtIndex:indexPath.row];
        
        cell.backgroundColor = [UIColor clearColor];
    } else {
        NSArray *keys = [self.data allKeys];
        keys = [keys sortedArrayUsingComparator:^(id a, id b) {
            return [a compare:b options:NSNumericSearch];
        }];
        NSString *key = keys[indexPath.section];
        
        
        contact = [self.data objectForKey:key][indexPath.row];
        
    }
    
    NSString *text = contact.firstName;
    if (contact.lastName) {
        text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
    }
    // [cell.textLabel setTextColor:[UIColor colorWithRed:242/255.0f green:242/255.0f blue:242/255.0f alpha:1.0f]];
    cell.name.text = text;
    cell.statusText.text = contact.statusText;
    
    NSLog(@"person.status %d", contact.status);
    
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
            [cell.redStatus setSelected:NO];
            [cell.greenStatus setSelected:NO];
            [cell.yellowStatus setSelected:NO];
            break;
            
        default:
            [cell.redStatus setSelected:NO];
            [cell.greenStatus setSelected:NO];
            [cell.yellowStatus setSelected:NO];
            break;
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Contact Detail Segue" sender:tableView];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //NSLog(@"didSelectRowAtIndexPath");
    
}


#pragma mark ABNewPersonViewControllerDelegate methods
// Dismisses the new-person view controller.
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
    
    if (person != nil)  //nil = Cancel button clicked
    {
        NSLog(@"person %@", person);
        [[SharedPreferences shared]setLastCallTime:0];
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.firstName BEGINSWITH[c] %@",searchText];
    
    NSArray *pomArray = [NSArray array];
    
    if (searchText != nil && searchText.length > 0) {
        NSString *firstLetter = [[searchText substringToIndex:1] uppercaseString];
        pomArray = [self.data objectForKey:firstLetter];
    }
    
    self.filteredContactArray = [NSMutableArray arrayWithArray:[pomArray filteredArrayUsingPredicate:predicate]];
    
  //  NSLog(@"filteredContactArray %d", self.filteredContactArray.count);

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
@end
