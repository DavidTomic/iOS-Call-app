//
//  StartViewController.m
//  CallAplication
//
//  Created by David Tomic on 06/08/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "StartViewController.h"
#import "UserRegistrationViewController.h"

@interface StartViewController ()

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
 //   [self performSelector:@selector(startMainVC) withObject:self afterDelay:1.5f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startMainVC{
    [self performSegueWithIdentifier:@"signUp Segue" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UserRegistrationViewController *vc = [segue destinationViewController];
    if ([[segue identifier] isEqualToString:@"logIn Segue"]) {
        vc.logIn = YES;
    }else if ([[segue identifier] isEqualToString:@"signUp Segue"]){
        vc.logIn = NO;
    }
    
    
}


@end
