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

#import "FavoritesViewController.h"

@interface TabBarViewController ()

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation TabBarViewController

//viewController methods
- (void)viewDidLoad {
    [super viewDidLoad];
    //area for testing
    //   NSLog(@"DT %@", [[DBManager sharedInstance]getAllDefaultTextsFromDb]);
    // Do any additional setup after loading the view.
  //  NSLog(@"TabBarViewController");
  //  [[UITabBar appearance] setTintColor:[UIColor redColor]];
      //  self.view.backgroundColor = [UIColor colorWithRed:35/255.0f green:40/255.0f blue:45/255.0f alpha:1.0f];
    
    
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:1.0f]];

    [[SharedPreferences shared]setLastCallTime:0];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationWillResign)
                                                name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidBecomeActiveNotification)
                                                name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveContactListReloadedNotification:)
                                                 name:@"ContactListReloaded"
                                               object:nil];
    
    [[MyConnectionManager sharedManager]requestGetDefaultTextsWithDelegate:self selector:@selector(responseToDefaultText:)];
    
    if (self.cameFromRegistration) {
        [self refreshCheckPhoneNumbers];
        [self refreshStatusInfo];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:(10) target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
    }
    
}
- (void)applicationWillResign {
    NSLog(@"applicationWillResign...");
    [self.timer invalidate];
    self.timer = nil;
}
- (void)applicationDidBecomeActiveNotification {
    NSLog(@"applicationDidBecomeActiveNotification...");
    [self refreshStatusInfo];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(10) target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
    
    if ([InternetStatus isNetworkAvailable]) {
        [[MyConnectionManager sharedManager]requestLogInWithDelegate:self selector:@selector(responseToLogIn:)];
    }
    
    [self refreshCheckPhoneNumbers];
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

//my methods
-(void)receiveContactListReloadedNotification:(NSNotification *)notification{
    // NSLog(@"receiveContactListReloadedNotification");
    
    [[SharedPreferences shared]setLastCallTime:0];
    
    [self refreshCheckPhoneNumbers];
    [self refreshStatusInfo];
}
-(void)onTick:(NSTimer*)timer
{
   //   NSLog(@"Tick...");
    [self refreshStatusInfo];
}
-(void)refreshStatusInfo{
        [[MyConnectionManager sharedManager]requestStatusInfoWithDelegate:self selector:@selector(responseToRequestStatusInfo:)];
}
-(void)refreshCheckPhoneNumbers{
    
    [[MyConnectionManager sharedManager] requestCheckPhoneNumbersWithDelegate:self selector:@selector(responseCheckPhoneNumbers:)];
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
                                                             
                                                             //    NSLog(@"person.firstName %@", person.firstName);
                                                             
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
                                                         
                                                         if ([[SharedPreferences shared] getLastContactsPhoneBookCount] == [personArray count]) {
                                                             NSLog(@"COUNT EQUAL");
                                                         }else {
                                                             [[SharedPreferences shared]setLastContactsPhoneBookCount:[personArray count]];
                                                             
                                                             
                                                             
                                                             NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                                                             personArray = [NSMutableArray arrayWithArray:[personArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]]];
                                                             
                                                             lettersArray = [NSArray arrayWithArray:[[lettersSet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
                                                             
                                                             NSLog(@"personArray %d", personArray.count);
                                                             
                                                             for (int i=0; i<lettersArray.count; i++) {
                                                                 NSMutableArray *pom = [[NSMutableArray alloc]init];
                                                                 
                                                                 for (int j=0; j<personArray.count; j++) {
                                                                     if ([lettersArray[i] isEqualToString:([[((Contact*)personArray[j]).firstName substringToIndex:1] uppercaseString])]) {
                                                                         [pom addObject:personArray[j]];
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

//response methods
-(void)responseToRequestStatusInfo:(NSDictionary *)dict{
    NSLog(@"responseToRequestStatusInfo %@", dict);
    
    if (dict) {
        
        NSDictionary *pom1 = [[dict objectForKey:@"RequestStatusInfoResponse"] objectForKey:@"RequestStatusInfoResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
          
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
   // NSLog(@"responseToLogIn %@", dict);
    if (dict) {
        NSDictionary *pom1 = [[dict objectForKey:@"LoginResponse"] objectForKey:@"LoginResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
            
            Myuser *user = [Myuser sharedUser];
            
            user.status = [[pom1 objectForKey:@"Status"] integerValue];
            user.statusText = [pom1 objectForKey:@"Statustext"];
            user.statusStartTime = [pom1 objectForKey:@"StartTimeStatus"];
            user.statusEndTime = [pom1 objectForKey:@"EndTimeStatus"];
            
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
-(void)responseCheckPhoneNumbers:(NSDictionary *)dict{
   // NSLog(@"responseCheckPhoneNumbers %@", dict);
    
    if (dict) {
        NSMutableArray *array = [Myuser sharedUser].checkPhoneNumberArray;
        [array removeAllObjects];
        
        NSDictionary *pom1 = [[dict objectForKey:@"CheckPhoneNumbersResponse"] objectForKey:@"CheckPhoneNumbersResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
            
            NSDictionary *pom2 = [pom1 objectForKey:@"PhoneNumbers"];
            
            id numbers = [pom2 objectForKey:@"string"];
            
            if([numbers isKindOfClass:[NSArray class]]){
               
                for (NSString *number in numbers) {
                    [array addObject:number];
                }
                
            }else if (numbers != nil){
                [array addObject:numbers];
            }
            
            
            
         //   NSLog(@"array %@", array);
            

        }
        
       // NSLog(@"responseCheckPhoneNumbers array %@", array);
    }
}
-(void)responseToAddMultipleContacts:(NSDictionary *)dict{
   // NSLog(@"responseToAddMultipleContacts %@", dict);
    
    if (dict) {
        NSDictionary *pom1 = [[dict objectForKey:@"AddMultiContactsResponse"] objectForKey:@"AddMultiContactsResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
            [[SharedPreferences shared]setLastCallTime:0];
            [self refreshStatusInfo];
            [self refreshCheckPhoneNumbers];
        }
    }
}



@end
