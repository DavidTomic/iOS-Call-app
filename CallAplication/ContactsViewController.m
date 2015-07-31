//
//  ContactsTableViewController.m
//  CallAplication
//
//  Created by David Tomic on 27/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "ContactsViewController.h"
#import <AddressBook/AddressBook.h>

@interface ContactsViewController()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *data;

@end

@implementation ContactsViewController

//-(void)viewDidLoad{
//    [super viewDidLoad];
//    
//    NSLog(@"viewDidLoad");
//    self.data = [[NSMutableDictionary alloc]init];
//    
//   [self getAllContacts];
//    
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
//    
//    
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
//}
//
//- (NSString *)documentsDirectory {
//    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//}
//
//
//
//-(void)getAllContacts{
//    CFErrorRef * error = NULL;
//    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
//    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
//                                             {
//                                                 if (granted)
//                                                 {
//                                                     dispatch_async(dispatch_get_main_queue(), ^{
//                                                         CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
//                                                         CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
//                                                         
//                                                         NSMutableArray *personArray = [[NSMutableArray alloc]init];
//                                                         NSArray *lettersArray = [[NSArray alloc]init];
//                                                         NSMutableSet *lettersSet = [[NSMutableSet alloc]init];
//                                                         for(int i = 0; i < numberOfPeople; i++){
//                                                             ABRecordRef abPerson = CFArrayGetValueAtIndex( allPeople, i );
//                                                             NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(abPerson, kABPersonFirstNameProperty));
//                                                             NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(abPerson, kABPersonLastNameProperty));
//                                                             ABMultiValueRef phoneNumbers = ABRecordCopyValue(abPerson, kABPersonPhoneProperty);
//                                                         //    NSLog(@"firstName %@", firstName);
//                                                             
//                                                             NSString *phoneNumber = nil;
//                                                             if (ABMultiValueGetCount(phoneNumbers) > 0) {
//                                                                 phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
//                                                             }
//                                                             Person *person = [[Person alloc]init];
//                                                             person.firstName = firstName;
//                                                             person.lastName = lastName;
//                                                             person.phoneNumber = phoneNumber;
//                                                             
//                                                             [personArray addObject:person];
//                                                             [lettersSet addObject:([(NSString*)[firstName substringToIndex:1] uppercaseString])];
//                                                             
//                                                             
//                                                             
////                                                             for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
////                                                                 NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
////                                                                
////                                                                 NSLog(@"Name:%@ %@ -> phoneNumber:%@", firstName, lastName, phoneNumber);
////                                                             }
//                                                             
//                                                         }
//                                                         
//                                                         NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
//                                                         personArray = [NSMutableArray arrayWithArray:[personArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]]];
//                                                         lettersArray = [NSArray arrayWithArray:[[lettersSet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
//                                                         
//                                                        // NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
//                                                         for (int i=0; i<lettersArray.count; i++) {
//                                                             NSMutableArray *pom = [[NSMutableArray alloc]init];
//                                                             
//                                                             for (int j=0; j<personArray.count; j++) {
//                                                                 if ([lettersArray[i] isEqualToString:([[((Person*)personArray[j]).firstName substringToIndex:1] uppercaseString])]) {
//                                                                     [pom addObject:personArray[j]];
//                                                                 }
//                                                             }
//                                                             
//                                                             [self.data setObject:pom forKey:lettersArray[i]];
//                                                         }
//                                                         
//                                                         NSLog(@"dict %@", self.data);
//                                                         
//                                                         [self.tableView reloadData];
//                                                         
//                                                     });
//                                                 }
//                                             });
//}
//
//-(void)addContact{
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
//}
//
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    // Return the number of sections.
//    return [[self.data allKeys] count];
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [self.data allKeys][section];
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    // Return the number of rows in the section.
//    NSString *key = [self.data allKeys][section];
//    return [[self.data objectForKey:key] count];
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
//    }
//    
//    NSString *key = [self.data allKeys][indexPath.section];
//    Person *person = [self.data objectForKey:key][indexPath.row];
//    cell.textLabel.text = person.firstName;
//    
//    return cell;
//}

@end
