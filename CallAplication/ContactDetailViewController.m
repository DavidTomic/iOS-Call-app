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
#import "Contact.h"
#import "Myuser.h"

@interface ContactDetailViewController ()<ABPersonViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *userPhone;

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

-(void)setValues{
    NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(self.people, kABPersonFirstNameProperty));
    NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(self.people, kABPersonLastNameProperty));
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(self.people, kABPersonPhoneProperty);
    NSString *phoneNumber = nil;
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    }
    
    NSString *text = firstName;
    if (lastName) {
        text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
    
    self.username.text = text;
    self.userPhone.text = phoneNumber;
    
    
    NSData *imgData2 = (__bridge NSData*)ABPersonCopyImageDataWithFormat(self.people, kABPersonImageFormatThumbnail);
    UIImage *img2 = [UIImage imageWithData:imgData2];
    
    NSLog(@"img2 %f", img2.size.width);
    
    NSLog(@"W %f", self.profileImage.frame.size.width);
    NSLog(@"H %f", self.profileImage.frame.size.height);
    
    if (img2.size.width > 0 && img2.size.height > 0) {
        [self.profileImage setImage:img2 forState:UIControlStateNormal];
        [self.profileImage setBackgroundColor:[UIColor clearColor]];
    }else {
        NSString *text = [[firstName substringToIndex:1] uppercaseString];
        if (lastName) {
            text = [NSString stringWithFormat:@"%@%@", text, [[lastName substringToIndex:1] uppercaseString]];
        }
        [self.profileImage setTitle:text forState:UIControlStateNormal];
    }
    

}

-(void)viewDidLayoutSubviews{
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.layer.borderWidth = 0;
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImage.clipsToBounds = YES;
}

- (IBAction)makeCall:(UIButton *)sender {
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(self.people, kABPersonPhoneProperty);
    NSString *phoneNumber = nil;
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    }
    
    NSLog(@"makeCall");
    if (phoneNumber) {
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *pNumber = [@"telprompt://" stringByAppendingString:phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pNumber]];
    }
    
}

- (IBAction)sendMessage:(id)sender {
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(self.people, kABPersonPhoneProperty);
    NSString *phoneNumber = nil;
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    }

    if(phoneNumber && [MFMessageComposeViewController canSendText]) {
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = [NSArray arrayWithObjects:phoneNumber, nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    
    
}

- (IBAction)favoritButtonPressed:(UIButton *)sender {
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)editButtonPressed:(UIBarButtonItem *)button{
    
    if (self.people)
    {
        [[Myuser sharedUser] refreshContactList];
        ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
        personViewController.personViewDelegate = self;
        personViewController.displayedPerson = self.people;
        personViewController.allowsEditing = YES;
        [self.navigationController pushViewController:personViewController animated:YES];
                personViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"return" style:UIBarButtonItemStyleBordered target:self action:@selector(ReturnFromPersonView:)];
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

-(void)ReturnFromPersonView:(UIBarButtonItem *)button{
    NSLog(@"ReturnFromPersonView");
}

#pragma mark ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person
                    property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    return YES;
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
