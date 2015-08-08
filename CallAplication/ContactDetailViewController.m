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

@interface ContactDetailViewController ()<ABPersonViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *userPhone;
@property (weak, nonatomic) IBOutlet UIButton *favoritButton;

@end

@implementation ContactDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed:)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    
    if (self.contact.favorit) {
        [self.favoritButton setImage:[UIImage imageNamed:@"star_full"] forState:UIControlStateNormal];
    }else{
        [self.favoritButton setImage:[UIImage imageNamed:@"star_empty"] forState:UIControlStateNormal];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setValues];
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
    

}

-(void)viewDidLayoutSubviews{
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
        
        NSString *pNumber = [@"telprompt://" stringByAppendingString:phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pNumber]];
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
    
    [[DBManager sharedInstance]addOrRemoveContactInFavoritWithRecordId:self.contact.recordId];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)editButtonPressed:(UIBarButtonItem *)button{
    
     CFErrorRef * error = NULL;
     ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
     ABRecordRef people = ABAddressBookGetPersonWithRecordID(addressBook, self.contact.recordId);
    
    if (people)
    {
        [[Myuser sharedUser] refreshContactList];
        ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
        personViewController.personViewDelegate = self;
        personViewController.displayedPerson = people;
        personViewController.allowsEditing = YES;
        [self.navigationController pushViewController:personViewController animated:YES];

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
