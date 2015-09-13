//
//  TabBarViewController.m
//  CallAplication
//
//  Created by David Tomic on 31/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "TabBarViewController.h"
//#import "DBManager.h"
#import "MyConnectionManager.h"

@interface TabBarViewController ()

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  //  NSLog(@"TabBarViewController");
  //  [[UITabBar appearance] setTintColor:[UIColor redColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:55/255.0f green:60/255.0f blue:65/255.0f alpha:1.0f]];
    
  //  self.view.backgroundColor = [UIColor colorWithRed:35/255.0f green:40/255.0f blue:45/255.0f alpha:1.0f];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationWillResign)
                                                name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidBecomeActiveNotification)
                                                name:UIApplicationDidBecomeActiveNotification object:nil];
    
    
    //area for testing
 //   NSLog(@"DT %@", [[DBManager sharedInstance]getAllDefaultTextsFromDb]);
    
}

- (void)applicationWillResign {
    NSLog(@"applicationWillResign...");
    [self.timer invalidate];
    self.timer = nil;
}

- (void)applicationDidBecomeActiveNotification {
    NSLog(@"applicationDidBecomeActiveNotification...");
    [self requsetStatusInfo];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
}

-(void)onTick:(NSTimer*)timer
{
      NSLog(@"Tick...");
    [self requsetStatusInfo];
}

-(void)requsetStatusInfo{
        [[MyConnectionManager sharedManager]requestStatusInfoWithDelegate:self selector:@selector(responseToRequestStatusInfo:)];
}

-(void)responseToRequestStatusInfo:(NSDictionary *)dict{
    NSLog(@"dict %@", dict);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


@end
