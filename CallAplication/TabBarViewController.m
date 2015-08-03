//
//  TabBarViewController.m
//  CallAplication
//
//  Created by David Tomic on 31/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"TabBarViewController");
  //  [[UITabBar appearance] setTintColor:[UIColor redColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:35/255.0f green:40/255.0f blue:45/255.0f alpha:1.0f]];
    
  //  self.view.backgroundColor = [UIColor colorWithRed:35/255.0f green:40/255.0f blue:45/255.0f alpha:1.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
