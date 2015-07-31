//
//  ViewController.m
//  CallAplication
//
//  Created by David Tomic on 27/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "ViewController.h"
#import "MyConnectionManager.h"
#import "Myuser.h";
#import "SharedPreferences.h"

@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberUITextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordUITextField;
@property (weak, nonatomic) IBOutlet UITextField *nameUITextField;
@property (weak, nonatomic) IBOutlet UITextField *emailUITextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yCoordinateOfTFHolder;
@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (nonatomic) BOOL logIn;

@end

@implementation ViewController

//viewController methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   // NSLog(@"W %f", self.view.frame.size.width);
   // NSLog(@"H %f", self.view.frame.size.height);

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.titleButton.titleLabel.text];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor grayColor]
                             range:NSMakeRange([self.titleButton.titleLabel.text rangeOfString:@"/"].location, self.titleButton.titleLabel.text.length-[self.titleButton.titleLabel.text rangeOfString:@"/"].location)];
    
    [self.titleButton setAttributedTitle:attributedString forState:UIControlStateNormal];

    [self observeKeyboard];
    [self addSpaceToTextFields];
    
    NSString * s = NSLocalizedString(@"TEST_STRING", @"");
    NSLog(@"string: %@", s);
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)showErrorAlert{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Please check your informations are correct" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

//IBAction methods
- (IBAction)titlePressed:(UIButton *)sender {
    
    [self.phoneNumberUITextField resignFirstResponder];
    [self.passwordUITextField resignFirstResponder];
    [self.nameUITextField resignFirstResponder];
    [self.emailUITextField resignFirstResponder];
    
    if (!self.logIn) {
        self.logIn = YES;
        
        [self.confirmButton setTitle:@"LOG IN" forState:UIControlStateNormal];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.titleButton.titleLabel.text];
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor grayColor]
                                 range:NSMakeRange(0, [self.titleButton.titleLabel.text rangeOfString:@"/"].location)];
        [self.titleButton setAttributedTitle:attributedString forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
            self.nameUITextField.alpha = 0.0f;
            self.emailUITextField.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.nameUITextField.hidden=YES;
            self.emailUITextField.hidden=YES;
        }];
        
        
    }else{
        self.logIn = NO;
        [self.confirmButton setTitle:@"SIGN UP" forState:UIControlStateNormal];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.titleButton.titleLabel.text];
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor grayColor]
                                 range:NSMakeRange([self.titleButton.titleLabel.text rangeOfString:@"/"].location, self.titleButton.titleLabel.text.length-[self.titleButton.titleLabel.text rangeOfString:@"/"].location)];
        [self.titleButton setAttributedTitle:attributedString forState:UIControlStateNormal];
        
        self.nameUITextField.hidden=NO;
        self.emailUITextField.hidden=NO;
        
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
            self.nameUITextField.alpha = 1.0f;
            self.emailUITextField.alpha = 1.0f;
        } completion:^(BOOL finished) {

        }];
    }
}
- (IBAction)confirmPressed:(UIButton *)sender {
    
    if (!self.logIn) {
        if (self.phoneNumberUITextField.text.length >5 && self.passwordUITextField.text.length > 3 && self.nameUITextField.text.length > 3 && self.emailUITextField.text.length > 5) {
            [[MyConnectionManager sharedManager]createAcountWithDelegate:self selector:@selector(responseToCreateUser:) phone:self.phoneNumberUITextField.text password:self.passwordUITextField.text name:self.nameUITextField.text email:self.emailUITextField.text language:1];
        }else{
            [self showErrorAlert];
        }

    }else{
       // [[MyConnectionManager sharedManager] logInAcountWithDelegate:self selector:@selector(responseToLogIn:)];
    }
    
    //
}





//observe methods
- (void)keyboardWillHide:(NSNotification *)notification {
    self.yCoordinateOfTFHolder.constant = 19.5;
}
- (void)keyboardWillShow:(NSNotification *)notification {
    if (!self.logIn)
    self.yCoordinateOfTFHolder.constant = 90;
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
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 1) {
            Myuser *user = [Myuser sharedUser];
            user.phoneNumber = self.phoneNumberUITextField.text;
            user.password = self.passwordUITextField.text;
            user.name = self.nameUITextField.text;
            user.email = self.emailUITextField.text;
            user.logedIn = YES;
            [[SharedPreferences shared]saveUserData:user];
            
            [self performSegueWithIdentifier:@"mainControllerSegue" sender:self];
            
            return;
        }
    }
    
    [self showErrorAlert];
}

-(void)responseToLogIn:(NSDictionary *)dict{
    NSLog(@"responseToLogIn %@", dict);
}

@end
