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

@interface ContactsViewController()<UITableViewDataSource, UITableViewDelegate, ABNewPersonViewControllerDelegate,UISearchBarDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic) ABAddressBookRef addressBook;
@property (nonatomic, strong) Myuser * myUser;
@property (nonatomic, strong) UIView *navView;

@property (strong,nonatomic) NSMutableArray *filteredContactArray;

@end

@implementation ContactsViewController

//viewController methods
-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.myUser = [Myuser sharedUser];
    
    float navViewHeight = 43;
    self.navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, navViewHeight)];
    
    UIView *circle = [[UIView alloc]initWithFrame:CGRectMake(10, navViewHeight/2-5, 10, 10)];
    circle.backgroundColor = [UIColor greenColor];
    circle.layer.cornerRadius = circle.frame.size.width / 2;
    circle.layer.borderWidth = 0;
    circle.clipsToBounds = YES;
    [self.navView addSubview:circle];
    
    UILabel *statusLabel = [[UILabel alloc]init];
    statusLabel.text = @"This is my status..";
    statusLabel.textColor = [UIColor lightGrayColor];
    [statusLabel setFont:[statusLabel.font fontWithSize:10]];
    [statusLabel sizeToFit];
    statusLabel.frame = CGRectMake(10, navViewHeight-statusLabel.frame.size.height-2, statusLabel.frame.size.width, statusLabel.frame.size.height);
    [self.navView addSubview:statusLabel];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(statusTapped:)];
    [self.navView addGestureRecognizer:tapRecognizer];
    
    [self.navigationController.navigationBar addSubview:self.navView];
    
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
    
}

-(void)receiveContactListReloadedNotification:(NSNotification *)notification{
    NSLog(@"receiveContactListReloadedNotification");
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

//my methods
-(void)reloadData{
    NSLog(@"relaodData %lu", (unsigned long)self.myUser.contactDictionary.count);
    
    self.data = [self.myUser.contactDictionary copy];
    
    [self.tableView reloadData];
}
-(void)statusTapped:(UITapGestureRecognizer *)tapRecognizer{
    NSLog(@"status tapped");
}

//IBAction methods
- (IBAction)addContactPressed:(UIBarButtonItem *)sender {
    ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
    picker.newPersonViewDelegate = self;
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
    [self presentViewController:navigation animated:YES completion:nil];
    
}

//delegate methods
#pragma mark UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    int count = 0;
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
    

    Contact *person = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
      //  NSLog(@"COUNT %d", self.filteredContactArray.count);
        person = [self.filteredContactArray objectAtIndex:indexPath.row];
        
        cell.backgroundColor = [UIColor clearColor];
    } else {
        NSArray *keys = [self.data allKeys];
        keys = [keys sortedArrayUsingComparator:^(id a, id b) {
            return [a compare:b options:NSNumericSearch];
        }];
        NSString *key = keys[indexPath.section];
        
        
        person = [self.data objectForKey:key][indexPath.row];
        
    }
    
    NSString *text = person.firstName;
    if (person.lastName) {
        text = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
    }
    // [cell.textLabel setTextColor:[UIColor colorWithRed:242/255.0f green:242/255.0f blue:242/255.0f alpha:1.0f]];
    cell.name.text = text;
    cell.statusText.text = @"this is my status";
    
    
    switch (person.status) {
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
        [self.myUser refreshContactList];
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
