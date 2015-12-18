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
#import "Myuser.h"

@interface KeyboardViewController()<JCDialPadDelegate>

@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) UIView *plusView;
@property (nonatomic, strong) JCDialPad *pad;

@end


@implementation KeyboardViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
//    NSLog(@"W %f", self.view.bounds.size.width);
//    NSLog(@"H %f", self.view.bounds.size.height);
  //  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper"]];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = self.view.bounds;
    frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - 12);
    
    self.pad = [[JCDialPad alloc] initWithFrame:frame];
    self.buttons =[JCDialPad defaultButtons];
    
    self.pad.buttons = [self.buttons arrayByAddingObjectsFromArray:@[self.callButton]];
    self.pad.delegate = self;
  //  pad.formatTextToPhoneNumber = NO;
    [self.pad setTintColor:[UIColor greenColor]];
    [self.view addSubview:self.pad];
    


}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.plusView) {
        for (JCPadButton *button in self.buttons){
            if ([button.input isEqualToString:@"0"]) {
                UIView *plusView = [[UIView alloc]initWithFrame:button.frame];
                UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(enterPlusSign:)];
                [plusView addGestureRecognizer:longGesture];
                UITapGestureRecognizer *taprecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterZeroSign:)];
                [plusView addGestureRecognizer:taprecognizer];
                [self.view addSubview:plusView];
                break;
            }
        }
    }

}

-(void)enterPlusSign:(UILongPressGestureRecognizer *)longGesture{
    if ( longGesture.state == UIGestureRecognizerStateEnded ) {
        [self.pad appendText:@"+"];
    }
}
-(void)enterZeroSign:(UITapGestureRecognizer *)tapGesture{
        [self.pad appendText:@"0"];
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
        
        NSString *phoneNumber = dialPad.rawText;
        
        [Myuser sharedUser].lastDialedPhoneNumber = phoneNumber;
        
        if (phoneNumber) {
            phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet] componentsJoinedByString:@""];
            // NSLog(@"phoneNumberA %@", phoneNumber);
            
            NSString *pNumber = [@"tel://" stringByAppendingString:phoneNumber];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pNumber]];
        }
        
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
