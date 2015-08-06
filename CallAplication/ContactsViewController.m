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

@interface ContactsViewController()<UITableViewDataSource, UITableViewDelegate, ABNewPersonViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic) ABAddressBookRef addressBook;
@property (nonatomic, strong) Myuser * myUser;

@end

@implementation ContactsViewController

//viewController methods
-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.myUser = [Myuser sharedUser];

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
    if([sender isKindOfClass:[UITableViewCell class]]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if(indexPath){
            if([[segue identifier]isEqualToString:@"Contact Detail Segue"]){
                if([segue.destinationViewController isKindOfClass:[ContactDetailViewController class]]){
                    
                    
                    NSArray *keys = [self.myUser.contactList allKeys];
                    keys = [keys sortedArrayUsingComparator:^(id a, id b) {
                        return [a compare:b options:NSNumericSearch];
                    }];
                    
                    NSString *key = keys[indexPath.section];
                    Contact *person = [self.myUser.contactList objectForKey:key][indexPath.row];
                    
                   NSLog(@"firstName %@", person.firstName);
                    NSLog(@"recordId %d", person.recordId);
                    
                    ContactDetailViewController *vc = (ContactDetailViewController *)segue.destinationViewController;
                    vc.people = ABAddressBookGetPersonWithRecordID(self.addressBook, person.recordId);
                }
            }
        }
    }
}

//my methods
-(void)reloadData{
    NSLog(@"relaodData %d", self.myUser.contactList.count);
    
    self.data = [self.myUser.contactList copy];
    
    [self.tableView reloadData];
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
    return [[self.data allKeys] count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *keys = [self.data allKeys];
    keys = [keys sortedArrayUsingComparator:^(id a, id b) {
        return [a compare:b options:NSNumericSearch];
    }];
    return keys[section];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *keys = [self.data allKeys];
    keys = [keys sortedArrayUsingComparator:^(id a, id b) {
        return [a compare:b options:NSNumericSearch];
    }];
    
    NSString *key = keys[section];
    return [[self.data objectForKey:key] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    NSArray *keys = [self.data allKeys];
    
    keys = [keys sortedArrayUsingComparator:^(id a, id b) {
        return [a compare:b options:NSNumericSearch];
    }];
    
    NSString *key = keys[indexPath.section];
    Contact *person = [self.data objectForKey:key][indexPath.row];
    NSString *text = person.firstName;
    if (person.lastName) {
        text = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
    }
    [cell.textLabel setTextColor:[UIColor colorWithRed:242/255.0f green:242/255.0f blue:242/255.0f alpha:1.0f]];
    cell.textLabel.text = text;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"didSelectRowAtIndexPath");
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSArray *keys = [self.data allKeys];
    keys = [keys sortedArrayUsingComparator:^(id a, id b) {
        return [a compare:b options:NSNumericSearch];
    }];
    return keys;
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
@end
