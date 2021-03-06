//
//  ContactDetailViewController.m
//  CallAplication
//
//  Created by David Tomic on 06/08/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "ContactDetailViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Contact.h"
#import "Myuser.h"
#import "DBManager.h"
#import "TabBarViewController.h"
#import "SharedPreferences.h"
#import "MyConnectionManager.h"

@interface ContactDetailViewController ()<ABNewPersonViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *userPhone;
@property (weak, nonatomic) IBOutlet UIButton *favoritButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;


@end

@implementation ContactDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed:)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    
    [self setValues];
    
}

-(void)updateContactDataFromAddressBook{
    CFErrorRef * error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 if (granted)
                                                 {
                                                     
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         
                                                         
                                                         ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, self.contact.recordId);
                                                         if (person) {
                                                             ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                                                             NSString *phoneNumber = nil;
                                                             if (ABMultiValueGetCount(phoneNumbers) > 0) {
                                                                 phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
                                                             }
                                                             
                                                             NSString *firstSign = [phoneNumber substringToIndex:1];
                                                             NSString *phoneNumberOnlyDigit = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                                                             if ([firstSign isEqualToString:@"+"]) {
                                                                 phoneNumber = [NSString stringWithFormat:@"%@%@", firstSign, phoneNumberOnlyDigit];
                                                             }
                                                             
                                                             NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                                                             NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                                                             
                                                             NSData *imgData2 = (__bridge NSData*)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
                                                             self.contact.image =[UIImage imageWithData:imgData2];
                                                             
                                                             if (![self.contact.phoneNumber isEqualToString:phoneNumber] ||
                                                                 ![self.contact.firstName isEqualToString:firstName] ||
                                                                 ![self.contact.lastName isEqualToString:lastName]) {
                                                                 self.contact.phoneNumber = phoneNumber;
                                                                 self.contact.firstName = firstName;
                                                                 self.contact.lastName = lastName;
                                                                 
                                                                 [[MyConnectionManager sharedManager]requestAddContactWithContact:self.contact delegate:self selector:nil];
                                                             }
                                                         }

                                                         CFRelease(addressBook);
                                                         
                                                         [self setValues];

                                                     });
                                                 }
                                                 
                                             });

}

-(void)setValues{
    
    NSString *text = self.contact.firstName;
    if (self.contact.lastName) {
        text = [NSString stringWithFormat:@"%@ %@", self.contact.firstName, self.contact.lastName];
    }
    
    self.username.text = text;
    self.userPhone.text = self.contact.phoneNumber;

    UIImage *img2 = self.contact.image;
    
    if (img2.size.width > 0 && img2.size.height > 0) {
        [self.profileImage setImage:img2 forState:UIControlStateNormal];
        [self.profileImage setBackgroundColor:[UIColor clearColor]];
    }else {
        NSString *text = [[self.contact.firstName substringToIndex:1] uppercaseString];
        if (self.contact.lastName) {
            text = [NSString stringWithFormat:@"%@%@", text, [[self.contact.lastName substringToIndex:1] uppercaseString]];
        }
        [self.profileImage setTitle:text forState:UIControlStateNormal];
    }
    
    if (self.contact.favorit) {
        [self.favoritButton setImage:[UIImage imageNamed:@"star_full"] forState:UIControlStateNormal];
    }else{
        [self.favoritButton setImage:[UIImage imageNamed:@"star_empty"] forState:UIControlStateNormal];
    }

    if (self.contact.status == Undefined) {
         [self.confirmButton setTitle:NSLocalizedString(@"Invite", nil) forState:UIControlStateNormal];
    }else {
        if ([[DBManager sharedInstance]getNotificationForPhoneNumber:self.contact.phoneNumber]){
            [self.confirmButton setTitle:NSLocalizedString(@"Remove notification", nil) forState:UIControlStateNormal];
        }else {
            [self.confirmButton setTitle:NSLocalizedString(@"Set notification", nil) forState:UIControlStateNormal];
        }
    }

}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.layer.borderWidth = 0;
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImage.clipsToBounds = YES;
}

- (IBAction)makeCall:(UIButton *)sender {

    NSString *phoneNumber = self.contact.phoneNumber;

    
    NSLog(@"makeCall");
    if (phoneNumber) {
        phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet] componentsJoinedByString:@""];
       // NSLog(@"phoneNumberA %@", phoneNumber);
        
        [Myuser sharedUser].lastDialedRecordId = self.contact.recordId;
        
        NSString *pNumber = [@"tel://" stringByAppendingString:phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pNumber]];
    }
    
}

- (IBAction)FacetimeCall:(UIButton *)sender {
    
    NSString *phoneNumber = self.contact.phoneNumber;
    
    if (phoneNumber) {
        phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet] componentsJoinedByString:@""];
        
        NSString *urlString = [@"facetime://" stringByAppendingString:phoneNumber];
        
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
        
        [[DBManager sharedInstance]addContactInRecentWithRecordId:self.contact.recordId phoneNumber:nil timestamp:(long long)([[NSDate date] timeIntervalSince1970] * 1000.0)];
    }
}

- (IBAction)sendMessage:(id)sender {
    
    NSString *phoneNumber = self.contact.phoneNumber;

    if(phoneNumber && [MFMessageComposeViewController canSendText]) {
        phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet] componentsJoinedByString:@""];
        
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = [NSArray arrayWithObjects:phoneNumber, nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    
    
}

- (IBAction)favoritButtonPressed:(UIButton *)sender {
    
    if (self.contact.favorit) {
        self.contact.favorit = NO;
        [sender setImage:[UIImage imageNamed:@"star_empty"] forState:UIControlStateNormal];
    }else{
        self.contact.favorit = YES;
        [sender setImage:[UIImage imageNamed:@"star_full"] forState:UIControlStateNormal];
    }
    
  //  NSLog(@"self.contact.recordId %d",self.contact.recordId);
    
    [[DBManager sharedInstance]addOrRemoveContactInFavoritWithRecordId:self.contact.recordId];
    [[MyConnectionManager sharedManager]requestAddContactWithContact:self.contact delegate:self selector:@selector(responseToaddFavorit:)];

}

-(void)responseToaddFavorit:(NSDictionary *)dict{
   // NSLog(@"responseToaddFavorit %@", dict);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)editButtonPressed:(UIBarButtonItem *)button{
    
    
  //  NSLog(@"self.contact.recordId %d", self.contact.recordId);
    
     CFErrorRef * error = NULL;
     ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
     ABRecordRef people = ABAddressBookGetPersonWithRecordID(addressBook, self.contact.recordId);
    
    if (people)
    {

        ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
        picker.newPersonViewDelegate = self;
        picker.displayedPerson = people;
        picker.navigationItem.title=@"Info";
        
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
        [self presentViewController:navigation animated:YES completion:nil];

    }
    else
    {
        // Show an alert if "Appleseed" is not in Contacts
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:@"Could not find Appleseed in the Contacts application"
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)confirmButtonPressed:(UIButton *)sender {
    
    if ([sender.currentTitle isEqualToString:NSLocalizedString(@"Invite", nil)]) {
        NSString *phoneNumber = self.contact.phoneNumber;
        
        if(phoneNumber && [MFMessageComposeViewController canSendText]) {
            phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet] componentsJoinedByString:@""];
            
            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
            controller.recipients = [NSArray arrayWithObjects:phoneNumber, nil];
            controller.messageComposeDelegate = self;
            controller.body = [Myuser sharedUser].smsInviteText;
            [self presentViewController:controller animated:YES completion:nil];
        }

    }else if ([sender.currentTitle isEqualToString:NSLocalizedString(@"Remove notification", nil)]){
        [self.confirmButton setTitle:NSLocalizedString(@"Set notification", nil) forState:UIControlStateNormal];
        [[DBManager sharedInstance] removeNotificationFromDbWithPhoneNumber:self.contact.phoneNumber];
    }else {
        [self.confirmButton setTitle:NSLocalizedString(@"Remove notification", nil) forState:UIControlStateNormal];
         [[DBManager sharedInstance] addNotificationToDbWithPhoneNumber:self.contact.phoneNumber name:self.contact.firstName status:self.contact.status];
    }
}

#pragma mark ABNewPersonViewControllerDelegate methods
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
    
    if (person != nil)  //nil = Cancel button clicked
    {
        NSLog(@"person %@", person);
        [self updateContactDataFromAddressBook];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
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
