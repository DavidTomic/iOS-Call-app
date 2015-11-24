//
//  ViewController.m
//  CallAplication
//
//  Created by David Tomic on 27/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "UserRegistrationViewController.h"
#import "MyConnectionManager.h"
#import "Myuser.h"
#import "SharedPreferences.h"
#import "DBManager.h"
#import "TabBarViewController.h"
#import "SVProgressHUD.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)


@interface UserRegistrationViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberUITextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordUITextField;
@property (weak, nonatomic) IBOutlet UITextField *nameUITextField;
@property (weak, nonatomic) IBOutlet UITextField *emailUITextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yCoordinateOfTFHolder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yTitleCoordinate;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@end

@implementation UserRegistrationViewController

//viewController methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   // NSLog(@"W %f", self.view.frame.size.width);
   // NSLog(@"H %f", self.view.frame.size.height);

//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.titleButton.titleLabel.text];
//    [attributedString addAttribute:NSForegroundColorAttributeName
//                             value:[UIColor grayColor]
//                             range:NSMakeRange([self.titleButton.titleLabel.text rangeOfString:@"/"].location, self.titleButton.titleLabel.text.length-[self.titleButton.titleLabel.text rangeOfString:@"/"].location)];
//    
//    [self.titleButton setAttributedTitle:attributedString forState:UIControlStateNormal];

    [self observeKeyboard];
    [self addSpaceToTextFields];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"mainControllerSegue"]) {
        [SVProgressHUD dismiss];
        TabBarViewController *destinationVC = segue.destinationViewController;
        destinationVC.cameFromRegistration = YES;
    }
}

//my methods
-(void)addSpaceToTextFields{
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.phoneNumberUITextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.phoneNumberUITextField setLeftView:spacerView];
    self.phoneNumberUITextField.delegate = self;
    [self.phoneNumberUITextField setReturnKeyType:UIReturnKeyDone];
    [self.phoneNumberUITextField setValue:[UIColor colorWithRed:157.0f/255 green:157.0f/255 blue:157.0f/255 alpha:1.0f]
                        forKeyPath:@"_placeholderLabel.textColor"];
    
    UIView *spacerView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.passwordUITextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.passwordUITextField setLeftView:spacerView2];
    self.passwordUITextField.delegate = self;
    [self.passwordUITextField setReturnKeyType:UIReturnKeyDone];
    [self.passwordUITextField setValue:[UIColor colorWithRed:157.0f/255 green:157.0f/255 blue:157.0f/255 alpha:1.0f]
                               forKeyPath:@"_placeholderLabel.textColor"];
    
    UIView *spacerView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.nameUITextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.nameUITextField setLeftView:spacerView3];
    self.nameUITextField.delegate = self;
    [self.nameUITextField setReturnKeyType:UIReturnKeyDone];
    [self.nameUITextField setValue:[UIColor colorWithRed:157.0f/255 green:157.0f/255 blue:157.0f/255 alpha:1.0f]
                               forKeyPath:@"_placeholderLabel.textColor"];
    
    UIView *spacerView4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.emailUITextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.emailUITextField setLeftView:spacerView4];
    self.emailUITextField.delegate = self;
    [self.emailUITextField setReturnKeyType:UIReturnKeyDone];
    [self.emailUITextField setValue:[UIColor colorWithRed:157.0f/255 green:157.0f/255 blue:157.0f/255 alpha:1.0f]
                               forKeyPath:@"_placeholderLabel.textColor"];
}
-(void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)showErrorAlert{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"Please check your informations are correct", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [SVProgressHUD dismiss];
}
-(void)showErrorAlertWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", @"") message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [SVProgressHUD dismiss];
}

//IBAction methods
-(IBAction)LogInPressed:(UIButton *)sender{
    
    [self.phoneNumberUITextField resignFirstResponder];
    [self.passwordUITextField resignFirstResponder];
    [self.nameUITextField resignFirstResponder];
    [self.emailUITextField resignFirstResponder];
    self.logIn = YES;
    
    [self.confirmButton setTitle:NSLocalizedString(@"LOG IN", nil) forState:UIControlStateNormal];
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        self.nameUITextField.alpha = 0.0f;
        self.emailUITextField.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.nameUITextField.hidden=YES;
        self.emailUITextField.hidden=YES;
    }];
}
-(IBAction)SignUpPressed:(UIButton *)sender{
    
    [self.phoneNumberUITextField resignFirstResponder];
    [self.passwordUITextField resignFirstResponder];
    [self.nameUITextField resignFirstResponder];
    [self.emailUITextField resignFirstResponder];
    self.logIn = NO;
    
    [self.confirmButton setTitle:NSLocalizedString(@"SIGN UP", nil) forState:UIControlStateNormal];
    self.nameUITextField.hidden=NO;
    self.emailUITextField.hidden=NO;
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        self.nameUITextField.alpha = 1.0f;
        self.emailUITextField.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)confirmPressed:(UIButton *)sender {
    
    if (!self.logIn) {
        if (self.phoneNumberUITextField.text.length < 5) {
            [self showErrorAlertWithMessage:NSLocalizedString(@"Please check your phone number", nil)];
        }else if(self.passwordUITextField.text.length < 3){
            [self showErrorAlertWithMessage:NSLocalizedString(@"Please check your password", nil)];
            return;
        }else if(self.nameUITextField.text.length < 1){
            [self showErrorAlertWithMessage:NSLocalizedString(@"Please check your name", nil)];
            return;
        }else if(self.emailUITextField.text.length < 5){
            [self showErrorAlertWithMessage:NSLocalizedString(@"Please check your email", nil)];
            return;
        }else{
            [SVProgressHUD show];
           [[MyConnectionManager sharedManager]createAcountWithDelegate:self selector:@selector(responseToCreateUser:) phone:self.phoneNumberUITextField.text password:self.passwordUITextField.text name:self.nameUITextField.text email:self.emailUITextField.text language:1];
        }

    }else{
        if (self.phoneNumberUITextField.text.length < 5) {
            [self showErrorAlertWithMessage:NSLocalizedString(@"Please check your phone number", nil)];
            return;
        }else if(self.passwordUITextField.text.length < 3){
            [self showErrorAlertWithMessage:NSLocalizedString(@"Please check your password", nil)];
            return;
        }else{
            [SVProgressHUD show];
            [[MyConnectionManager sharedManager] getAcountSetupWithDelegate:self selector:@selector(responseToGetAcountSetupWithDelegate:) phone:self.phoneNumberUITextField.text password:self.passwordUITextField.text];
        }
    }

}

//observe methods
- (void)keyboardWillHide:(NSNotification *)notification {
    self.yCoordinateOfTFHolder.constant = 20;
    self.yTitleCoordinate.constant = 40;
}
- (void)keyboardWillShow:(NSNotification *)notification {
    
    if (!self.logIn){
        self.yCoordinateOfTFHolder.constant = 80;
        
        if(IS_IPHONE_4_OR_LESS){
            self.yTitleCoordinate.constant = 8;
        }else {
            self.yTitleCoordinate.constant = 30;
        }
    }
    
}

//delegate methods
#pragma mark - UITextFieldDelegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

//response methods
-(void)responseToCreateUser:(NSDictionary *)dict{
    NSLog(@"responseToCreateUser %@", dict);
    
    if (dict) {
        NSDictionary *pom1 = [[dict objectForKey:@"CreateAccountResponse"] objectForKey:@"CreateAccountResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
            Myuser *user = [Myuser sharedUser];
            
            NSString *firstSign = [self.phoneNumberUITextField.text substringToIndex:1];
            NSString *phoneNumberOnlyDigit = [[self.phoneNumberUITextField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
            if ([firstSign isEqualToString:@"+"]) {
                phoneNumberOnlyDigit = [NSString stringWithFormat:@"%@%@", firstSign, phoneNumberOnlyDigit];
            }
            
            user.phoneNumber = phoneNumberOnlyDigit;
            user.password = self.passwordUITextField.text;
            
            [[MyConnectionManager sharedManager]requestAddMultipleContactsWithDelegate:self selector:@selector(responseToAddMultipleContacts:)];
            
            return;
        }else if ([[pom1 objectForKey:@"Result"] integerValue] == 0){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Phone number already exists", nil) message:NSLocalizedString(@"Please change number or Log in with existng phone number", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [SVProgressHUD dismiss];
            return;
        }
    }
    
    [self showErrorAlert];
}
-(void)responseToGetAcountSetupWithDelegate:(NSDictionary *)dict{
    NSLog(@"responseToGetAcountSetupWithDelegate %@", dict);
    
    if (dict) {
        NSDictionary *pom1 = [[dict objectForKey:@"GetAccountSetupResponse"] objectForKey:@"GetAccountSetupResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
            
            NSDictionary *pom2 = [pom1 objectForKey:@"AccountSetup"];
            
            Myuser *user = [Myuser sharedUser];
            user.phoneNumber = [pom2 objectForKey:@"Phonenumber"];
            user.password = self.passwordUITextField.text;
            user.name = [pom2 objectForKey:@"Name"];
            user.email = [pom2 objectForKey:@"Email"];
            user.logedIn = YES;
            
            
            NSString *lCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
            enum Language language;
            
            if ([lCode isEqualToString:@"en"]) {
                language = English;
            }else if ([lCode isEqualToString:@"da"]){
                language = Danish;
            }else{
                language = Default;
            }
            
            user.language = language;
            
            NSLog(@"language %u", user.language);
            [[SharedPreferences shared]saveUserData:user];
            

            NSDictionary *dfDict = [pom1 objectForKey:@"DefaultText"];
            
            id texts = [dfDict objectForKey:@"string"];
            
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
            
            
            
            [self performSegueWithIdentifier:@"mainControllerSegue" sender:self];
            
            return;
        }
    }
    
    [self showErrorAlert];
}
-(void)responseToAddMultipleContacts:(NSDictionary *)dict{
    NSLog(@"responseToAddMultipleContacts %@", dict);
    
    if (dict) {
        NSDictionary *pom1 = [[dict objectForKey:@"AddMultiContactsResponse"] objectForKey:@"AddMultiContactsResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
            
            Myuser *user = [Myuser sharedUser];
            
            NSString *firstSign = [self.phoneNumberUITextField.text substringToIndex:1];
            NSString *phoneNumberOnlyDigit = [[self.phoneNumberUITextField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
            if ([firstSign isEqualToString:@"+"]) {
                phoneNumberOnlyDigit = [NSString stringWithFormat:@"%@%@", firstSign, phoneNumberOnlyDigit];
            }
            
            user.phoneNumber = phoneNumberOnlyDigit;
            user.password = self.passwordUITextField.text;
            user.name = self.nameUITextField.text;
            user.email = self.emailUITextField.text;
            user.logedIn = YES;
            
            NSString *lCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
            enum Language language;
            
            if ([lCode isEqualToString:@"en"]) {
                language = English;
            }else if ([lCode isEqualToString:@"da"]){
                language = Danish;
            }else{
                language = English;
            }
            
            user.language = language;
            
            NSLog(@"language %u", user.language);
            
            [[SharedPreferences shared]saveUserData:user];
            
            int count = 0;
            NSArray *pom = [user.contactDictionary allValues];
            for (NSArray *array in pom){
                count += array.count;
            }
            
            [[SharedPreferences shared]setLastContactsPhoneBookCount:count];
            
            [self performSegueWithIdentifier:@"mainControllerSegue" sender:self];
        }else {
            [self showErrorAlert];
        }
    }else {
        [self showErrorAlert];
    }
}

@end
