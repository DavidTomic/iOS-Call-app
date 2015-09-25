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

//@property (nonatomic) ABAddressBookRef addressBook;

@end

@implementation Myuser

static Myuser *myUser;

+(Myuser *)sharedUser
{
    if (!myUser) {
        
        myUser = [[Myuser alloc]init];
        [[SharedPreferences shared]loadUserData:myUser];
        [myUser refreshContactList];
    }
    return myUser;
}

-(NSMutableDictionary *)contactDictionary{
    
    if(!_contactDictionary) _contactDictionary= [[NSMutableDictionary alloc]init];
    return _contactDictionary;
}

-(NSMutableArray *)checkPhoneNumberArray{
    
    if(!_checkPhoneNumberArray) _checkPhoneNumberArray= [[NSMutableArray alloc]init];
    return _checkPhoneNumberArray;
}


-(void)refreshContactList{
    self.contactDictionary = nil;
    
   // NSLog(@"refreshContactList");
    NSArray *favoritRecordIds = [[DBManager sharedInstance]getAllContactRecordIdsFromFavoritTable];
    
    CFErrorRef * error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 if (granted)
                                                 {
                                                     
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
                                                         CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
                                                     
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
                                                             
                                                            NSLog(@"person.firstName %d", person.recordId);
                                                             
                                                             for (int i=0; i<favoritRecordIds.count; i++) {
                                                                 if (person.recordId == [favoritRecordIds[i] integerValue]) {
                                                                     person.favorit = YES;
                                                                 //    NSLog(@"favorit %@", person.phoneNumber);
                                                                     break;
                                                                 }
                                                             }

                                                             [personArray addObject:person];
                                                             [lettersSet addObject:([(NSString*)[firstName substringToIndex:1] uppercaseString])];
                                                             
                                                         }
                                                     
                                                        CFRelease(allPeople);
                                                        CFRelease(addressBook);
                                                  //
                                                     
                                                     
                                                         NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                                                         personArray = [NSMutableArray arrayWithArray:[personArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]]];
                                                         
                                                         lettersArray = [NSArray arrayWithArray:[[lettersSet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
                                                     
                                                     //     NSLog(@"personArray %d", personArray.count);
                                                     
                                                         for (int i=0; i<lettersArray.count; i++) {
                                                             NSMutableArray *pom = [[NSMutableArray alloc]init];
                                                             
                                                             for (int j=0; j<personArray.count; j++) {
                                                                 if ([lettersArray[i] isEqualToString:([[((Contact*)personArray[j]).firstName substringToIndex:1] uppercaseString])]) {
                                                                     [pom addObject:personArray[j]];
                                                                 }
                                                             }
                                                             
                                                             
                                                             [self.contactDictionary setObject:pom forKey:lettersArray[i]];
                                                         }
  
                                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"ContactListReloaded"
                                                                                                             object:self];
                                                     });
                                                 }
                                                 
                                             });

}

@end
