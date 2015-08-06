//
//  KeyboardViewController.m
//  CallAplication
//
//  Created by David Tomic on 27/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "KeyboardViewController.h"
#import "JCDialPad.h"
#import "JCPadButton.h"
#import "FontasticIcons.h"

@interface KeyboardViewController()<JCDialPadDelegate>

@property (nonatomic, strong) NSTimer *timer;

@end


@implementation KeyboardViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    NSLog(@"W %f", self.view.bounds.size.width);
    NSLog(@"H %f", self.view.bounds.size.height);
  //  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper"]];
    
    JCDialPad *pad = [[JCDialPad alloc] initWithFrame:self.view.bounds];
    pad.buttons = [[JCDialPad defaultButtons] arrayByAddingObjectsFromArray:@[self.callButton]];
    pad.delegate = self;
    [pad setTintColor:[UIColor greenColor]];
    [self.view addSubview:pad];
    
    
    //self.timer = [NSTimer scheduledTimerWithTimeInterval: 3.0 target: self
             //                                         selector: @selector(callAfterSixtySecond:) userInfo: nil repeats: YES];
    
    //[self.timer invalidate];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void) callAfterSixtySecond:(NSTimer*)t
{
    NSLog(@"timer");

}

- (JCPadButton *)callButton
{
    FIIconView *iconView = [[FIIconView alloc] initWithFrame:CGRectMake(0, 0, 65, 65)];
    iconView.backgroundColor = [UIColor clearColor];
    iconView.icon = [FIFontAwesomeIcon phoneIcon];
    iconView.padding = 15;
    iconView.iconColor = [UIColor whiteColor];
    JCPadButton *callButton = [[JCPadButton alloc] initWithInput:@"P" iconView:iconView subLabel:@""];
    callButton.backgroundColor = [UIColor colorWithRed:0.261 green:0.837 blue:0.319 alpha:1.000];
    callButton.borderColor = [UIColor colorWithRed:0.261 green:0.837 blue:0.319 alpha:1.000];
    return callButton;
}

- (BOOL)dialPad:(JCDialPad *)dialPad shouldInsertText:(NSString *)text forButtonPress:(JCPadButton *)button
{
    if ([text isEqualToString:@"P"]) {
        
        NSString *phoneNumber = [@"telprompt://" stringByAppendingString:@"+385955679733"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        
        
//        UIWebView *callWebview = [[UIWebView alloc] init];
//        callWebview.frame = self.view.frame;
//        [self.view addSubview:callWebview];
//        NSURL *telURL = [NSURL URLWithString:@"telprompt:0955679733"];
//        [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
        
        return NO;
    }
    return YES;
}



@end
