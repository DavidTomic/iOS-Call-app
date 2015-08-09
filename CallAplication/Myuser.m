//
//  Myuser.m
//  CallAplication
//
//  Created by David Tomic on 31/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "Myuser.h"
#import "SharedPreferences.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Contact.h"
#import "DBManager.h"

@interface Myuser()

@property (nonatomic) ABAddressBookRef addressBook;

@end

@implementation Myuser

static Myuser *myUser;

+(Myuser *)sharedUser
{
    if (!myUser) {
        CFErrorRef * error = NULL;
        myUser = [[Myuser alloc]init];
        myUser.addressBook = ABAddressBookCreateWithOptions(NULL, error);
        [[SharedPreferences shared]loadUserData:myUser];
    }
    return myUser;
}

-(NSMutableDictionary *)contactDictionary{
    
    if(!_contactDictionary) _contactDictionary= [[NSMutableDictionary alloc]init];
    return _contactDictionary;
}

-(void)refreshContactList{
    self.contactDictionary = nil;
    
    NSArray *contacts = [[DBManager sharedInstance] getContactsFromDb];
    NSArray *favoritRecordIds = [[DBManager sharedInstance]getAllContactRecordIdsFromFavoritTable];
    
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 if (granted)
                                                 {
                                                     
                                                   //  dispatch_async(dispatch_get_main_queue(), ^{
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
                                                             
                                                             NSData *imgData2 = (__bridge NSData*)ABPersonCopyImageDataWithFormat(abPerson, kABPersonImageFormatThumbnail);
                                                             UIImage *image = [UIImage imageWithData:imgData2];
                                                            
                                                             
                                                             int recordId = ABRecordGetRecordID(abPerson);
                                                             
                                                             if (!firstName) {
                                                                 continue;
                                                             }
                                                             
                                                             NSString *phoneNumber = nil;
                                                             if (ABMultiValueGetCount(phoneNumbers) > 0) {
                                                                 phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
                                                             }
                                                             Contact *person = [[Contact alloc]init];
                                                             person.firstName = firstName;
                                                             person.lastName = lastName;
                                                             person.phoneNumber = phoneNumber;
                                                             person.recordId = recordId;
                                                             person.image = image;
                                                             
                                                             for (int i=0; i<favoritRecordIds.count; i++) {
                                                                 if (person.recordId == [favoritRecordIds[i] integerValue]) {
                                                                     person.favorit = YES;
                                                                     NSLog(@"favorit %@", person.phoneNumber);
                                                                     break;
                                                                 }
                                                             }
                                                             
                                                             
//                                                             for (NSArray *array in contacts){
//                                                                 
//                                                                 if ([array[0] isEqualToString:person.firstName]) {
//                                                                     
//                                                                     person.status = [array[1] intValue];
//                                                                     person.statusText = array[2];
//                                                                     person.endTime = array[3];
//                                                                     
//                                                                     break;
//                                                                 }
//                                                                 
//                                                             }
                                                             
                                                             
                                                             
                                                             
//                                                             if ([firstName isEqualToString:@"Test"]) {
//                                                                 NSLog(@"recordId %d", recordId);
//                                                             }
                                                             
                                                             [personArray addObject:person];
                                                             [lettersSet addObject:([(NSString*)[firstName substringToIndex:1] uppercaseString])];
                                                             
                                                             
                                                             
                                                             //                                                             for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
                                                             //                                                                 NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                                                             //
                                                             //                                                                 NSLog(@"Name:%@ %@ -> phoneNumber:%@", firstName, lastName, phoneNumber);
                                                             //                                                             }
                                                             
                                                         }
                                                     
                                                     
                                                         NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                                                         personArray = [NSMutableArray arrayWithArray:[personArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]]];
                                                         
                                                         lettersArray = [NSArray arrayWithArray:[[lettersSet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
                                                     
//                                                      NSSortDescriptor *sorter2 = [[NSSortDescriptor alloc] initWithKey:@"recordId" ascending:YES];
//                                                     
//                                                      NSMutableArray *pom = [NSMutableArray arrayWithArray:[personArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter2]]];
//                                                     
//                                                         for (int i=0; i<pom.count; i++) {
//                                                         NSLog(@"pom %d", ((Contact *)pom[i]).recordId);
//                                                         }
                                                     
                                                         for (int i=0; i<lettersArray.count; i++) {
                                                             NSMutableArray *pom = [[NSMutableArray alloc]init];
                                                             
                                                             for (int j=0; j<personArray.count; j++) {
                                                                 if ([lettersArray[i] isEqualToString:([[((Contact*)personArray[j]).firstName substringToIndex:1] uppercaseString])]) {
                                                                     [pom addObject:personArray[j]];
                                                                 }
                                                             }
                                                             
                                                               //    NSLog(@"setObject lettersArray %@", lettersArray[i]);
                                                             [self.contactDictionary setObject:pom forKey:lettersArray[i]];
                                                         }
                                                         
                                                          NSLog(@"contactList.count %d", self.contactDictionary.count);
                                                         
                                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"ContactListReloaded"
                                                                                                             object:self];

                                             //        });
                                                 }
                                                 
                                                
                                                 
                                                 
                                                 
                                                 
                                             });

}

@end
