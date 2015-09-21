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
#import "SharedPreferences.h"
#import "InternetStatus.h"

@interface TabBarViewController ()

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation TabBarViewController

//viewController methods
- (void)viewDidLoad {
    [super viewDidLoad];
    //area for testing
    //   NSLog(@"DT %@", [[DBManager sharedInstance]getAllDefaultTextsFromDb]);
    // Do any additional setup after loading the view.
  //  NSLog(@"TabBarViewController");
  //  [[UITabBar appearance] setTintColor:[UIColor redColor]];
      //  self.view.backgroundColor = [UIColor colorWithRed:35/255.0f green:40/255.0f blue:45/255.0f alpha:1.0f];
    
    
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:1.0f]];

    [[SharedPreferences shared]setLastCallTime:0];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationWillResign)
                                                name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidBecomeActiveNotification)
                                                name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[MyConnectionManager sharedManager]requestDefaultTextsWithDelegate:self selector:@selector(responseToDefaultText:)];
    
}
- (void)applicationWillResign {
    NSLog(@"applicationWillResign...");
    [self.timer invalidate];
    self.timer = nil;
}
- (void)applicationDidBecomeActiveNotification {
    NSLog(@"applicationDidBecomeActiveNotification...");
    [self requsetStatusInfo];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1000*60*3) target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
    
    if ([InternetStatus isNetworkAvailable]) {
        [[MyConnectionManager sharedManager]requestLogInWithDelegate:self selector:@selector(responseToLogIn:)];
    }
 
}
- (void)viewWillLayoutSubviews
{
    float tabBarHeigt = 70;
    CGRect tabFrame = self.tabBar.frame; //self.TabBar is IBOutlet of your TabBar
    tabFrame.size.height = tabBarHeigt;
    tabFrame.origin.y = self.view.frame.size.height - tabBarHeigt;
    self.tabBar.frame = tabFrame;
    
    [UITabBarItem appearance].titlePositionAdjustment = UIOffsetMake(0, -4);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


//my methods
-(void)onTick:(NSTimer*)timer
{
      NSLog(@"Tick...");
    [self requsetStatusInfo];
}
-(void)requsetStatusInfo{
        [[MyConnectionManager sharedManager]requestStatusInfoWithDelegate:self selector:@selector(responseToRequestStatusInfo:)];
}
-(void)refreshCheckPhoneNumbers{
    
}


-(void)showErrorAlert{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", nil) message:NSLocalizedString(@"Please check your informations are correct", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

//response methods
-(void)responseToRequestStatusInfo:(NSDictionary *)dict{
    NSLog(@"responseToRequestStatusInfo %@", dict);
}
-(void)responseToDefaultText:(NSDictionary *)dict{
    NSLog(@"responseToDefaultText %@", dict);
}
-(void)responseToLogIn:(NSDictionary *)dict{
    NSLog(@"responseToLogIn %@", dict);
}




@end
