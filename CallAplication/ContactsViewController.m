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
#import "Person.h"

@interface ContactsViewController()<UITableViewDataSource, UITableViewDelegate,ABPersonViewControllerDelegate,
ABNewPersonViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *data;

@property (nonatomic) ABAddressBookRef addressBook;

@end

@implementation ContactsViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
   // [self.tableView setEditing: YES animated: YES];
    
   // self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
 //   self.navigationController.navigationBar.tintColor = [UIColor blueColor];
    
    
    
    NSLog(@"viewDidLoad");
    self.data = [[NSMutableDictionary alloc]init];
    
   [self getAllContacts];
    
    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSDirectoryEnumerator *dirnum = [[NSFileManager defaultManager] enumeratorAtPath: @"/var/wireless"];
//    NSString *nextItem = [NSString string];
//    while( (nextItem = [dirnum nextObject])) {
//        
//        NSLog(@"%@", nextItem);
//        
//        if ([[nextItem pathExtension] isEqualToString: @"db"] ||
//            [[nextItem pathExtension] isEqualToString: @"sqlitedb"]) {
//            NSLog(@"%@", nextItem);
//            if ([fileManager isReadableFileAtPath:nextItem]) {
//                NSLog(@"%@", nextItem);
//            } 
//        } 
//    }
    
    
//    NSError *error = nil;
//    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
//
//    NSArray *itemsPath = [[NSFileManager defaultManager]
//                          contentsOfDirectoryAtPath:resourcePath error:&error];
//    NSLog(@"itemsPath %@", itemsPath);
//
//    NSString *documentsDirectory = [self documentsDirectory];
//    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
//    NSLog(@"files %@", files);
}

//- (NSString *)documentsDirectory {
//    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//}


-(void)getAllContacts{
    CFErrorRef * error = NULL;
    self.addressBook = ABAddressBookCreateWithOptions(NULL, error);
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 if (granted)
                                                 {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
                                                         CFIndex numberOfPeople = ABAddressBookGetPersonCount(self.addressBook);
                                                         
                                                         NSMutableArray *personArray = [[NSMutableArray alloc]init];
                                                         NSArray *lettersArray = [[NSArray alloc]init];
                                                         
                                                         
                                                         NSMutableSet *lettersSet = [[NSMutableSet alloc]init];
                                                         
                                                         
                                                         for(int i = 0; i < numberOfPeople; i++){
                                                             ABRecordRef abPerson = CFArrayGetValueAtIndex( allPeople, i );
                                                             NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(abPerson, kABPersonFirstNameProperty));
                                                             NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(abPerson, kABPersonLastNameProperty));
                                                             ABMultiValueRef phoneNumbers = ABRecordCopyValue(abPerson, kABPersonPhoneProperty);
                                                             
                                                             int recordId = ABRecordGetRecordID(abPerson);
//                                                             NSLog(@"firstName %@", firstName);
//                                                             NSLog(@"lastName %@", lastName);
                                                             
                                                             if (!firstName) {
                                                                 continue;
                                                             }
                                                             
                                                             NSString *phoneNumber = nil;
                                                             if (ABMultiValueGetCount(phoneNumbers) > 0) {
                                                                 phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
                                                             }
                                                             Person *person = [[Person alloc]init];
                                                             person.firstName = firstName;
                                                             person.lastName = lastName;
                                                             person.phoneNumber = phoneNumber;
                                                             person.recordId = recordId;
                                                             
                                                             [personArray addObject:person];
                                                             [lettersSet addObject:([(NSString*)[firstName substringToIndex:1] uppercaseString])];
                                                             
                                                             
                                                             
//                                                             for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
//                                                                 NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
//                                                                
//                                                                 NSLog(@"Name:%@ %@ -> phoneNumber:%@", firstName, lastName, phoneNumber);
//                                                             }
                                                             
                                                         }
                                                         
                                                         NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
                                                         personArray = [NSMutableArray arrayWithArray:[personArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]]];
                                                         
                                                         lettersArray = [NSArray arrayWithArray:[[lettersSet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
                                                         
                                                
                                                      //   NSLog(@"lettersArray %@", lettersArray);
                                                        
                                                         for (int i=0; i<lettersArray.count; i++) {
                                                             NSMutableArray *pom = [[NSMutableArray alloc]init];
                                                             
                                                             for (int j=0; j<personArray.count; j++) {
                                                                 if ([lettersArray[i] isEqualToString:([[((Person*)personArray[j]).firstName substringToIndex:1] uppercaseString])]) {
                                                                     [pom addObject:personArray[j]];
                                                                 }
                                                             }
                                                             
                                                       //      NSLog(@"setObject lettersArray %@", lettersArray[i]);
                                                             [self.data setObject:pom forKey:lettersArray[i]];
                                                         }
                                                         
                                                         NSLog(@"Keys %@", [self.data allKeys]);
                                                         [self.tableView reloadData];
                                                         
                                                     });
                                                 }
                                             });
}

-(void)addContact{
//    CFErrorRef error = NULL;
//    NSLog(@"%@", [self description]);
//    ABAddressBookRef iPhoneAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
//    
//    ABRecordRef newPerson = ABPersonCreate();
//    
//    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, @"Tester", &error);
//    ABRecordSetValue(newPerson, kABPersonLastNameProperty, @"testinjo", &error);
//    
//    ABMutableMultiValueRef multiPhone =     ABMultiValueCreateMutable(kABMultiStringPropertyType);
//    ABMultiValueAddValueAndLabel(multiPhone, @"+38593777888", kABPersonPhoneMainLabel, NULL);
//    ABMultiValueAddValueAndLabel(multiPhone, @"Other", kABOtherLabel, NULL);
// //   ABMultiValueAddValueAndLabel(multiPhone, @"+38593777888", kABPersonPhone, NULL);
//    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
//    CFRelease(multiPhone);
//    // ...
//    // Set other properties
//    // ...
//    ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
//    
//    ABAddressBookSave(iPhoneAddressBook, &error);
//    CFRelease(newPerson);
//    CFRelease(iPhoneAddressBook);
//    if (error != NULL)
//    {
//        CFStringRef errorDesc = CFErrorCopyDescription(error);
//        NSLog(@"Contact not saved: %@", errorDesc);
//        CFRelease(errorDesc);        
//    }
}


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
    Person *person = [self.data objectForKey:key][indexPath.row];
    NSString *text = person.firstName;
    if (person.lastName) {
        text = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
    }
    cell.textLabel.text = text;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"didSelectRowAtIndexPath");
    
    NSArray *keys = [self.data allKeys];
    keys = [keys sortedArrayUsingComparator:^(id a, id b) {
        return [a compare:b options:NSNumericSearch];
    }];
    
    NSString *key = keys[indexPath.section];
    Person *person = [self.data objectForKey:key][indexPath.row];
    
    NSLog(@"firstName %@", person.firstName);
    [self editContactViewControllerWithPerson:person];
}



- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSArray *keys = [self.data allKeys];
    keys = [keys sortedArrayUsingComparator:^(id a, id b) {
        return [a compare:b options:NSNumericSearch];
    }];
    return keys;
}

- (IBAction)addContactPressed:(UIBarButtonItem *)sender {
    ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
    picker.newPersonViewDelegate = self;
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
    [self presentViewController:navigation animated:YES completion:nil];

}

-(void)editContactViewControllerWithPerson:(Person *)person
{
    
    ABRecordRef people = ABAddressBookGetPersonWithRecordID(self.addressBook, person.recordId);
    
    if (people != nil)
    {
        ABPersonViewController *picker = [[ABPersonViewController alloc] init];
        picker.personViewDelegate = self;
        picker.displayedPerson = people;
        // Allow users to edit the person’s information
        picker.allowsEditing = YES;
        [self.navigationController pushViewController:picker animated:YES];
    }
    else
    {
        // Show an alert if "Appleseed" is not in Contacts
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Could not find Appleseed in the Contacts application"
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark ABNewPersonViewControllerDelegate methods
// Dismisses the new-person view controller.
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person
                    property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    return YES;
}

@end
