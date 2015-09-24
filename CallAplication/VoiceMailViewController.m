//
//  VoiceMailViewController.m
//  CallAplication
//
//  Created by David Tomic on 22/09/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "VoiceMailViewController.h"
#import "SharedPreferences.h"

@interface VoiceMailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation VoiceMailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.textField setLeftViewMode:UITextFieldViewModeAlways];
    [self.textField setLeftView:spacerView];
    
    self.textField.text = [[SharedPreferences shared]getVoiceMailNumber];
    // Do any additional setup after loading the view.

}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    

    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dialClicked:(UIButton *)sender {
    [self.textField resignFirstResponder];
    [[SharedPreferences shared]setVoiceMailNumber:self.textField.text];
    
    NSString *phoneNumber = self.textField.text;
    
    [Myuser sharedUser].lastDialedPhoneNumber = phoneNumber;
    
    if (phoneNumber) {
        phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet] componentsJoinedByString:@""];
        // NSLog(@"phoneNumberA %@", phoneNumber);
        
        NSString *pNumber = [@"telprompt://" stringByAppendingString:phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pNumber]];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
