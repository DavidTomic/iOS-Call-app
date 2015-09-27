//
//  SettingsDetailViewController.m
//  CallAplication
//
//  Created by David Tomic on 25/09/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "SettingsDetailViewController.h"
#import "MyConnectionManager.h"
#import "Myuser.h"
#import "SharedPreferences.h"
#import "DBManager.h"

@interface SettingsDetailViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *bSave;
@property (weak, nonatomic) IBOutlet UIButton *bEnglish;
@property (weak, nonatomic) IBOutlet UIButton *bDanish;

@end

@implementation SettingsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.editDefaultText){
        self.title = NSLocalizedString(@"Edit default text", nil);
        self.textField.text = self.item;
    }else {
        self.title = self.item;
    }
    
    
    if (![self.item isEqualToString:NSLocalizedString(@"Set Language", nil)] || self.editDefaultText) {
        self.bEnglish.hidden = YES;
        self.bDanish.hidden = YES;
        self.textField.hidden = NO;
        self.bSave.hidden = NO;
    }
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.textField setLeftViewMode:UITextFieldViewModeAlways];
    [self.textField setLeftView:spacerView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)saveClicked:(UIButton *)sender {
    
    if (self.textField.text.length < 2) {
        [self showErrorMessage];
        return;
    }
    
    if ([self.item isEqualToString:NSLocalizedString(@"Add new default text", nil)]) {
        
        [[DBManager sharedInstance]addDefaultTextToDefaultTextDb:self.textField.text];
        [[MyConnectionManager sharedManager]requestSetDefaultTextsWithDelegate:self selector:@selector(responseToSetDefaultText:)];
        
    }else if (self.editDefaultText){
        
        [[DBManager sharedInstance]removeDefaultTextFromDefaultTextDb:self.textId];
        [[DBManager sharedInstance]addDefaultTextToDefaultTextDb:self.textField.text];
        
        [[MyConnectionManager sharedManager]requestSetDefaultTextsWithDelegate:self selector:@selector(responseToSetDefaultText:)];
        
    }else {
        
        Myuser *user = [Myuser sharedUser];
        
        NSString *newPhoneNumber = user.phoneNumber;
        NSString *newPassword = user.password;
        NSString *email = user.email;
        NSString *name = user.name;

        
        if ([self.item isEqualToString:NSLocalizedString(@"Phone number", )]) {
            newPhoneNumber = self.textField.text;
        }else if ([self.item isEqualToString:NSLocalizedString(@"Password", )]){
            newPassword = self.textField.text;
        }else if ([self.item isEqualToString:NSLocalizedString(@"Name", )]){
            name = self.textField.text;
        }else{
            email = self.textField.text;
        }
        
        
        [[MyConnectionManager sharedManager]requestUpdateAccountWithNewPhoneNumber:newPhoneNumber password:newPassword name:name email:email language:user.language delegate:self selector:@selector(responseToUpdateAccount:)];
    }

    
    
}


- (IBAction)languageClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)showErrorMessage{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Please check your informations are correct", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)responseToUpdateAccount:(NSDictionary *)dict{
    if (dict) {
        NSDictionary *pom1 = [[dict objectForKey:@"UpdateAccountResponse"] objectForKey:@"UpdateAccountResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
            
            Myuser *user = [Myuser sharedUser];
            
            if ([self.item isEqualToString:NSLocalizedString(@"Phone number", )]) {
                user.phoneNumber = self.textField.text;
            }else if ([self.item isEqualToString:NSLocalizedString(@"Password", )]){
                user.password = self.textField.text;
            }else if ([self.item isEqualToString:NSLocalizedString(@"Name", )]){
                user.name = self.textField.text;
            }else{
                user.email = self.textField.text;
            }
            
            [[SharedPreferences shared]saveUserData:user];
            
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            [self showErrorMessage];
        }
    }
}
-(void)responseToSetDefaultText:(NSDictionary *)dict{
    if (dict) {
        NSDictionary *pom1 = [[dict objectForKey:@"SetDefaultTextResponse"] objectForKey:@"SetDefaultTextResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            [self showErrorMessage];
        }
        
    }
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //limit the size :
    int limit = 40;
    return !([textField.text length]>limit && [string length] > range.length);
}

@end
