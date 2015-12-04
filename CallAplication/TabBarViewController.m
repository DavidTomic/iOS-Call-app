//
//  TabBarViewController.m
//  CallAplication
//
//  Created by David Tomic on 31/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "TabBarViewController.h"
#import "DBManager.h"
#import "MyConnectionManager.h"
#import "SharedPreferences.h"
#import "InternetStatus.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Contact.h"
#import "VoiceMailViewController.h"
#import "FavoritesViewController.h"
#import "iToast.h"
#import <AudioToolbox/AudioToolbox.h>

@interface TabBarViewController ()<UITabBarControllerDelegate>

@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *contactList;

@end

@implementation TabBarViewController

//viewController methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    //area for testing
    //   NSLog(@"DT %@", [[DBManager sharedInstance]getAllDefaultTextsFromDb]);
    // Do any additional setup after loading the view.
  //  NSLog(@"TabBarViewController");
  //  [[UITabBar appearance] setTintColor:[UIColor redColor]];
      //  self.view.backgroundColor = [UIColor colorWithRed:35/255.0f green:40/255.0f blue:45/255.0f alpha:1.0f];
    
    
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:1.0f]];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationWillResign)
                                                name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidBecomeActiveNotification)
                                                name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveContactListReloadedNotification:)
                                                 name:@"ContactListReloaded"
                                               object:nil];
    
    [[MyConnectionManager sharedManager]requestGetDefaultTextsWithDelegate:self selector:@selector(responseToDefaultText:)];
    
    [[SharedPreferences shared]setLastCallTime:@"2000-01-01T00:00:00"];
    if (self.cameFromRegistration) {
        [self checkAndUpdateAllContact];
        [self refreshStatusInfo];
        [self startRequestInfoTimer];
    }

}
- (void)applicationWillResign {
    NSLog(@"applicationWillResign...");
    [self stopRequestInfoTimer];
}
- (void)applicationDidBecomeActiveNotification {
    NSLog(@"applicationDidBecomeActiveNotification...");
    [self refreshStatusInfo];
    [self startRequestInfoTimer];
    
    if ([InternetStatus isNetworkAvailable]) {
        [[MyConnectionManager sharedManager]requestLogInWithDelegate:self selector:@selector(responseToLogIn:)];
    }
    
  //  [self refreshCheckPhoneNumbers];
    [self checkAndUpdateAllContact];
    

    [self.selectedViewController viewWillAppear:false];
}
- (void)viewWillLayoutSubviews
{
    float tabBarHeigt = 65;
    CGRect tabFrame = self.tabBar.frame; //self.TabBar is IBOutlet of your TabBar
    tabFrame.size.height = tabBarHeigt;
    tabFrame.origin.y = self.view.frame.size.height - tabBarHeigt;
    self.tabBar.frame = tabFrame;
    
    [UITabBarItem appearance].titlePositionAdjustment = UIOffsetMake(0, -4);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    NSInteger tabIndex = [[tabBarController viewControllers] indexOfObject:viewController];
    
    if (tabIndex == 4) {
        
        NSString *phoneNumber = [[SharedPreferences shared]getVoiceMailNumber];
        
        if (phoneNumber && phoneNumber.length > 0) {
            phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet] componentsJoinedByString:@""];
            // NSLog(@"phoneNumberA %@", phoneNumber);
            
            NSString *pNumber = [@"tel://" stringByAppendingString:phoneNumber];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pNumber]];
        }else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"Please enter your voicemail number in application settings", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        return NO;
    }else {
        return YES;
    }
    
}

//my methods
-(void)receiveContactListReloadedNotification:(NSNotification *)notification{
    // NSLog(@"receiveContactListReloadedNotification");
    [self refreshStatusInfo];
}
-(void)startRequestInfoTimer{
    
    NSInteger repeatTime = [Myuser sharedUser].requestStatusInfoSeconds;
    if (repeatTime < 10) {
        repeatTime = 10;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(repeatTime) target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
}
-(void)stopRequestInfoTimer{
    [self.timer invalidate];
    self.timer = nil;
}
-(void)onTick:(NSTimer*)timer
{
   //   NSLog(@"Tick...");
    [self refreshStatusInfo];
}
-(void)refreshStatusInfo{
        [[MyConnectionManager sharedManager]requestStatusInfoWithDelegate:self selector:@selector(responseToRequestStatusInfo:)];
}
-(void)checkAndUpdateAllContact{
   // NSLog(@"checkAndUpdateAllContact");
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSArray *favoritRecordIds = [[DBManager sharedInstance]getAllContactRecordIdsFromFavoritTable];
    
    CFErrorRef * error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 if (granted)
                                                 {
                                                     
                                                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                         CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
                                                         CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
                                                         
                                                         self.contactList = [[NSMutableArray alloc]init];
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
                                                             
                                                             if (!phoneNumber) {
                                                                 continue;
                                                             }
                                                             
                                                             NSString *firstSign = [phoneNumber substringToIndex:1];
                                                             NSString *phoneNumberOnlyDigit = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                                                             if ([firstSign isEqualToString:@"+"]) {
                                                                 phoneNumberOnlyDigit = [NSString stringWithFormat:@"%@%@", firstSign, phoneNumberOnlyDigit];
                                                             }
                                                             
                                                             Contact *person = [[Contact alloc]init];
                                                             person.firstName = firstName;
                                                             person.lastName = lastName;
                                                             person.phoneNumber = phoneNumberOnlyDigit;
                                                             person.recordId = recordId;
                                                             person.image = image;
                                                             person.status = Undefined;
                                                             
                                                        //     NSLog(@"phoneNumberOnlyDigit %@", phoneNumberOnlyDigit);
                                                             
                                                             //    NSLog(@"person.firstName %@", person.firstName);
                                                             
                                                             for (int i=0; i<favoritRecordIds.count; i++) {
                                                                 if (person.recordId == [favoritRecordIds[i] integerValue]) {
                                                                     person.favorit = YES;
                                                                     
                                                                     break;
                                                                 }
                                                             }
                                                             
                                                             [self.contactList addObject:person];
                                                             [lettersSet addObject:([(NSString*)[firstName substringToIndex:1] uppercaseString])];
                                                             
                                                         }
                                                         
                                                         CFRelease(allPeople);
                                                         CFRelease(addressBook);
                                                         
                                                         NSMutableArray *newContactList = [NSMutableArray array];
                                                         
                                                         NSMutableArray *oldContactList = [NSMutableArray array];
                                                         NSMutableArray *pomList = [NSMutableArray array];
                                                         
                                                         NSArray *currentList = [[DBManager sharedInstance]getAllPhoneNumbersFromDb];
                                                         
                                                         // add new contacts to server (user add contact out of this app)
                                                         for (Contact *contact in self.contactList){
                                                             if (![currentList containsObject:contact.phoneNumber]) {
                                                                 [newContactList addObject:contact];
                                                             }
                                                         }
                                                         
                                                    //     NSLog(@"newContactList %@", newContactList);
                                                         
                                                         // delete old contacts from server
                                                         for (Contact *contact in self.contactList){
                                                             [pomList addObject:contact.phoneNumber];
                                                         }
                                                         
                                                         for (NSString *phoneNumber in currentList){
                                                             if (![pomList containsObject:phoneNumber]) {
                                                                 [oldContactList addObject:phoneNumber];
                                                             }
                                                         }
                                                         
                                                     //    NSLog(@"oldContactList %@", oldContactList);
                                                         
                                                         if (oldContactList.count > 0) {
                                                             [self deleteContactsOnServer:oldContactList];
                                                         }
                                                         
                                                         if (newContactList.count > 0 || oldContactList.count > 0) {
                                          
                                                             NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                                                             self.contactList = [NSMutableArray arrayWithArray:[self.contactList sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]]];
                                                             
                                                             lettersArray = [NSArray arrayWithArray:[[lettersSet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
                                                             
                                                             for (int i=0; i<lettersArray.count; i++) {
                                                                 NSMutableArray *pom = [[NSMutableArray alloc]init];
                                                                 
                                                                 for (int j=0; j<self.contactList.count; j++) {
                                                                     if ([lettersArray[i] isEqualToString:([[((Contact*)self.contactList[j]).firstName substringToIndex:1] uppercaseString])]) {
                                                                         [pom addObject:self.contactList[j]];
                                                                     }
                                                                 }
                                                                 
                                                                 [dict setObject:pom forKey:lettersArray[i]];
                                                             }

                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 //Your main thread code goes in here
                                                                 NSLog(@"Im on the main thread");
                                                                [Myuser sharedUser].contactDictionary = [dict mutableCopy];
                                                                 
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"ContactListReloaded"
                                                                                                                     object:self];
                                                                 
                                                                 [[MyConnectionManager sharedManager]requestAddMultipleContactsWithDelegate:self selector:@selector(responseToAddMultipleContacts:)];
                                                             });
                                                        }
                                                     });
                                                     
                                                 }
                                                 
                                             });

}
-(void)showErrorAlert{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", nil) message:NSLocalizedString(@"Please check your informations are correct", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
-(void)deleteContactsOnServer:(NSArray *)phoneNumberList{
    for (NSString *phoneNumber in phoneNumberList){
        [[MyConnectionManager sharedManager]requestDeleteContactWithPhoneNumberToDelete:phoneNumber
                                                                               delegate:self selector:@selector(responseToDeleteContact:)];
    }
}

//response methods
-(void)responseToRequestStatusInfo:(NSDictionary *)dict{
    NSLog(@"responseToRequestStatusInfo %@", dict);
    
    if (dict) {
        
        NSDictionary *pom1 = [[dict objectForKey:@"RequestStatusInfoResponse"] objectForKey:@"RequestStatusInfoResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
            
            NSArray *notificationArray = [[DBManager sharedInstance] getAllNotificationsFromDb];
            
            [[SharedPreferences shared]setLastCallTime:[pom1 objectForKey:@"ExecutionTime"]];
          
            id pom2 = [[pom1 objectForKey:@"UserStatus"] objectForKey:@"csUserStatus"];
            NSArray *pomArray = [[Myuser sharedUser].contactDictionary allValues];

            if ([pom2 isKindOfClass:[NSArray class]]) {
                for (NSDictionary *contactDict in pom2){
                    NSString *phoneNumber = [contactDict objectForKey:@"PhoneNumber"];
                    
                    for (NSArray *array in pomArray){
                        for (Contact *contact in array){
                            if ([contact.phoneNumber isEqualToString:phoneNumber]) {
                                //      NSLog(@"phoneNumber nasao %@", phoneNumber);
                                NSString *sText = [contactDict objectForKey:@"StatusText"];
                                
                                if (sText && [sText isEqualToString:@"(null)"]) {
                                    sText = nil;
                                }
                                
                                contact.statusText = sText;
                                contact.status = [[contactDict objectForKey:@"Status"]integerValue];
                                
                                for (Contact *notificationContact in notificationArray){
                                    if ([contact.phoneNumber isEqualToString:notificationContact.phoneNumber] && contact.status != notificationContact.status) {
                                        [self setNotificationForContact:contact];
                                    }
                                }
                                
                                goto outer;
                            }
                        }
                    }
                outer:;
                    
                }
            }else {
                
                NSDictionary *contactDict = pom2;
                NSString *phoneNumber = [contactDict objectForKey:@"PhoneNumber"];
                
                for (NSArray *array in pomArray){
                    for (Contact *contact in array){
                        if ([contact.phoneNumber isEqualToString:phoneNumber]) {
                            //      NSLog(@"phoneNumber nasao %@", phoneNumber);
                            NSString *sText = [contactDict objectForKey:@"StatusText"];
                            
                            if (sText && [sText isEqualToString:@"(null)"]) {
                                sText = nil;
                            }
                            
                            contact.statusText = sText;
                            contact.status = [[contactDict objectForKey:@"Status"]integerValue];
                            
                            for (Contact *notificationContact in notificationArray){
                                if ([contact.phoneNumber isEqualToString:notificationContact.phoneNumber] && contact.status != notificationContact.status) {
                                    [self setNotificationForContact:contact];
                                }
                            }
                            
                            goto outer2;
                        }
                    }
                }
                
                outer2:;
                
            }
            

            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshStatus"
                                                                object:self];
        }
        
    }

}
-(void)responseToDefaultText:(NSDictionary *)dict{
    //NSLog(@"responseToDefaultText %@", dict);
    if (dict) {
        NSDictionary *pom1 = [[dict objectForKey:@"GetDefaultTextResponse"] objectForKey:@"GetDefaultTextResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
            NSDictionary *pom2 = [pom1 objectForKey:@"DefaultText"];
            
            id texts = [pom2 objectForKey:@"string"];
            
            NSMutableArray *textList = [[NSMutableArray alloc]init];
            
            if([texts isKindOfClass:[NSArray class]]){
                
                for (NSString *text in texts) {
                    [textList addObject:text];
                }
                
            }else if(texts != nil){
                [textList addObject:texts];
            }
            

            if (textList.count > 0) {
                 [[DBManager sharedInstance]saveDefaultTextsToDb:textList];
            }
           
        }
        
    }
}
-(void)responseToLogIn:(NSDictionary *)dict{
    NSLog(@"responseToLogIn %@", dict);
    if (dict) {
        NSDictionary *pom1 = [[dict objectForKey:@"LoginResponse"] objectForKey:@"LoginResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
            
            Myuser *user = [Myuser sharedUser];
            
            user.status = [[pom1 objectForKey:@"Status"] integerValue];
            user.statusText = [pom1 objectForKey:@"Statustext"];
//            user.statusStartTime = [pom1 objectForKey:@"StartTimeStatus"];
//            user.statusEndTime = [pom1 objectForKey:@"EndTimeStatus"];
            user.requestStatusInfoSeconds = [[pom1 objectForKey:@"UpdateStatusOnList"]integerValue];
            
            NSArray *pom2 = [[pom1 objectForKey:@"InviteSMS"] objectForKey:@"csInviteSMS"];
            
            for (NSDictionary *dict in pom2){
                if (user.language == [[dict objectForKey:@"Language"]integerValue]) {
                    user.smsInviteText = [dict objectForKey:@"SMSText"];
                }
            }
            
            [[SharedPreferences shared] saveUserData:user];
            
        }else {
            //TODO delete user
        }
    }
}
//-(void)responseCheckPhoneNumbers:(NSDictionary *)dict{
//   // NSLog(@"responseCheckPhoneNumbers %@", dict);
//    
//    if (dict) {
//        NSMutableArray *array = [Myuser sharedUser].checkPhoneNumberArray;
//        [array removeAllObjects];
//        
//        NSDictionary *pom1 = [[dict objectForKey:@"CheckPhoneNumbersResponse"] objectForKey:@"CheckPhoneNumbersResult"];
//        
//        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
//            
//            NSDictionary *pom2 = [pom1 objectForKey:@"PhoneNumbers"];
//            
//            id numbers = [pom2 objectForKey:@"string"];
//            
//            if([numbers isKindOfClass:[NSArray class]]){
//               
//                for (NSString *number in numbers) {
//                    [array addObject:number];
//                }
//                
//            }else if (numbers != nil){
//                [array addObject:numbers];
//            }
//            
//            
//            
//         //   NSLog(@"array %@", array);
//            
//
//        }
//        
//       // NSLog(@"responseCheckPhoneNumbers array %@", array);
//    }
//}
-(void)responseToAddMultipleContacts:(NSDictionary *)dict{
    NSLog(@"responseToAddMultipleContacts %@", dict);
    
    if (dict) {
        NSDictionary *pom1 = [[dict objectForKey:@"AddMultiContactsResponse"] objectForKey:@"AddMultiContactsResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
            
            NSMutableArray *pom = [NSMutableArray array];
            for (Contact *contact in self.contactList){
                [pom addObject:contact.phoneNumber];
            }
            
            [[DBManager sharedInstance]addContactsPhoneNumbersToDb:pom];
            [[SharedPreferences shared]setLastCallTime:@"2000-01-01T00:00:00"];
            [self refreshStatusInfo];
        }
    }
}
-(void)responseToDeleteContact:(NSDictionary *)dict{
     NSLog(@"responseToDeleteContact %@", dict);
    
    if (dict) {
        NSDictionary *pom1 = [[dict objectForKey:@"DeleteContactResponse"] objectForKey:@"DeleteContactResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
            NSMutableArray *pom = [NSMutableArray array];
            for (Contact *contact in self.contactList){
                [pom addObject:contact.phoneNumber];
            }
            
            [[DBManager sharedInstance]addContactsPhoneNumbersToDb:pom];
            [self refreshStatusInfo];
        }
    }
}

- (void)setNotificationForContact:(Contact *)contact {
    NSString *message = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Changed status to: ", nil), [self getStatusTextForStatus:contact.status]];
//    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//    localNotification.fireDate = [NSDate date];
//    localNotification.alertBody = message;
//    localNotification.soundName = UILocalNotificationDefaultSoundName;
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
//    iToastSettings *theSettings = [iToastSettings getSharedSettings];
//    theSettings.duration = 4000;
//    [[[iToast makeText:message]
//      setGravity:iToastGravityCenter] show];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:contact.firstName message:message
                                                  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    
    NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/sms-received1.caf"]; // see list below
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL,&soundID);
    AudioServicesPlaySystemSound(soundID);
    
    [[DBManager sharedInstance] removeNotificationFromDbWithPhoneNumber:contact.phoneNumber];
}

-(NSString *)getStatusTextForStatus:(Status)status{
    NSString *statusText = @"";
    
    switch (status) {
        case Red_status:
            statusText = NSLocalizedString(@"busy", nil);
            break;
        case Green_status:
            statusText = NSLocalizedString(@"online", nil);
            break;
        case Yellow_status:
            statusText = NSLocalizedString(@"not available", nil);
            break;
        default:
            statusText = NSLocalizedString(@"speaking", nil);
            break;
    }
    
    return statusText;
}


@end
