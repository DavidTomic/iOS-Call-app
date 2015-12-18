//
//  SetStatusViewController.m
//  CallAplication
//
//  Created by David Tomic on 25/09/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "SetStatusViewController.h"
#import "Myuser.h"
#import "MyConnectionManager.h"
#import "SharedPreferences.h"
#import "DBManager.h"
#import "TimerNotification.h"
#import "SVProgressHUD.h"

@interface SetStatusViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *redCircle;
@property (weak, nonatomic) IBOutlet UIImageView *yellowCircle;
@property (weak, nonatomic) IBOutlet UIImageView *greenCircle;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *iAmLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *iamOnlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;


@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *textPicker;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *setButtonBottomConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerBottomConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textPickerBottomConstraint;


@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *endTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *startTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *clearTimerButton;

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@property (strong, nonatomic) NSMutableArray *textArray;

@property (nonatomic) BOOL datePickerActive;
@property (nonatomic) BOOL startDateActive;

@end

@implementation SetStatusViewController

//VC methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Set status", nil);
    
    [self refreshMyStatusUITo:[Myuser sharedUser].status];
    
    NSArray *pom = [[DBManager sharedInstance]getAllDefaultTextsFromDb];
    self.textArray = [NSMutableArray array];
    
    for (NSDictionary *dict in pom) {
        [self.textArray addObject:[dict objectForKey:@"text"]];
    }
    
    if (self.textArray.count == 0) {
        [self.textArray addObject:@"-"];
    }
    
    NSString *statusText = [Myuser sharedUser].statusText != nil ? [Myuser sharedUser].statusText : @"";
    self.textField.text = statusText;
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *statusStartTime = [df dateFromString: [Myuser sharedUser].statusStartTime];
    NSDate *statusEndTime = [df dateFromString: [Myuser sharedUser].statusEndTime];
    
    if (statusStartTime && statusEndTime &&
        [statusEndTime compare:statusStartTime] == NSOrderedDescending &&
        [statusEndTime compare:currentDate] == NSOrderedDescending) {
        
        [df setDateFormat:@"dd-MM·HH:mm"];
        
        self.startDate = statusStartTime;
        self.endDate = statusEndTime;
        
        self.startTimeLabel.text =  [[df stringFromDate:self.startDate] uppercaseString];
        self.endTimeLabel.text =  [[df stringFromDate:self.endDate] uppercaseString];
        
        [self refreshMyStatusUITo:[Myuser sharedUser].timerStatus];
        
        NSString *statusText = [Myuser sharedUser].timerStatusText != nil ? [Myuser sharedUser].timerStatusText : @"";
        self.textField.text = statusText;
    }
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
     [SVProgressHUD dismiss];
}

//my methods
-(void)refreshMyStatusUITo:(Status)status{
    
    switch (status) {
        case Red_status:
            [self.redCircle setHighlighted:YES];
            [self.yellowCircle setHighlighted:NO];
            [self.greenCircle setHighlighted:NO];
            
            self.startTimeButton.hidden = NO;
            self.iAmLabel.hidden = NO;
            self.startTimeLabel.hidden = NO;
            self.startTimeButton.hidden = NO;
            self.iamOnlineLabel.hidden = NO;
            self.endTimeLabel.hidden = NO;
            self.endTimeButton.hidden = NO;
            self.clearTimerButton.hidden = NO;
            
            self.iAmLabel.text = NSLocalizedString(@"Set red status from:", nil);
            self.iamOnlineLabel.text = NSLocalizedString(@"Set red status to:", nil);
            
            break;
        case Green_status:
            [self.redCircle setHighlighted:NO];
            [self.yellowCircle setHighlighted:NO];
            [self.greenCircle setHighlighted:YES];
            self.datePickerBottomConstraint.constant = -162;
            self.textPickerBottomConstraint.constant = -162;
            self.setButtonBottomConstraint.constant = -204;
            self.confirmButton.hidden = NO;
            self.startTimeButton.hidden = YES;
            self.iAmLabel.hidden = YES;
            self.startTimeLabel.hidden = YES;
            self.startTimeButton.hidden = YES;
            self.iamOnlineLabel.hidden = YES;
            self.endTimeLabel.hidden = YES;
            self.endTimeButton.hidden = YES;
            self.clearTimerButton.hidden = YES;
            break;
        case Yellow_status:
            [self.redCircle setHighlighted:NO];
            [self.yellowCircle setHighlighted:YES];
            [self.greenCircle setHighlighted:NO];
            
            self.startTimeButton.hidden = NO;
            self.iAmLabel.hidden = NO;
            self.startTimeLabel.hidden = NO;
            self.startTimeButton.hidden = NO;
            self.iamOnlineLabel.hidden = NO;
            self.endTimeLabel.hidden = NO;
            self.endTimeButton.hidden = NO;
            self.clearTimerButton.hidden = NO;
            
            self.iAmLabel.text = NSLocalizedString(@"Set yellow status from:", nil);
            self.iamOnlineLabel.text = NSLocalizedString(@"Set yellow status to:", nil);
            
            break;
        default:
            [self.redCircle setHighlighted:NO];
            [self.yellowCircle setHighlighted:NO];
            [self.greenCircle setHighlighted:YES];
            self.datePickerBottomConstraint.constant = -162;
            self.textPickerBottomConstraint.constant = -162;
            self.setButtonBottomConstraint.constant = -204;
            self.confirmButton.hidden = NO;
            self.startTimeButton.hidden = YES;
            self.iAmLabel.hidden = YES;
            self.startTimeLabel.hidden = YES;
            self.startTimeButton.hidden = YES;
            self.iamOnlineLabel.hidden = YES;
            self.endTimeLabel.hidden = YES;
            self.endTimeButton.hidden = YES;
            self.clearTimerButton.hidden = YES;
            break;
    }
}
-(void)setItemsToVisible:(BOOL)visible{
    self.confirmButton.hidden = visible;
    
    if (![self.greenCircle isHighlighted]) {
        self.startTimeButton.hidden = visible;
        self.iAmLabel.hidden = visible;
        self.startTimeLabel.hidden = visible;
        self.startTimeButton.hidden = visible;
        self.iamOnlineLabel.hidden = visible;
        self.endTimeLabel.hidden = visible;
        self.endTimeButton.hidden = visible;
        self.clearTimerButton.hidden = visible;
    }
}
-(void)showErrorAlert{
     [SVProgressHUD dismiss];
    [[SharedPreferences shared]loadUserData:[Myuser sharedUser]];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"Status not updated", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

//IBAction methods
- (IBAction)selectTextPressed:(UIButton *)sender {
    [self.textField resignFirstResponder];
    [self setItemsToVisible:YES];
    self.datePickerBottomConstraint.constant = -162;

     [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.4 animations:^{
           self.textPickerBottomConstraint.constant = 0;
            self.setButtonBottomConstraint.constant = 162;
         [self.view layoutIfNeeded];
    }];
    
    self.datePickerActive = NO;
}
- (IBAction)setStartTimePressed:(UIButton *)sender {
    [self setItemsToVisible:YES];
    self.textPickerBottomConstraint.constant = -162;

    [self.datePicker setDate:[NSDate date]];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.2 animations:^{
        self.datePickerBottomConstraint.constant = 0;
        self.setButtonBottomConstraint.constant = 162;
        [self.view layoutIfNeeded];
    }];
    
    self.startDateActive = YES;
    self.datePickerActive = YES;
}
- (IBAction)setEndTimePressed:(UIButton *)sender {
    [self setItemsToVisible:YES];
    self.textPickerBottomConstraint.constant = -162;

    if (self.startDate) {
        [self.datePicker setDate:self.startDate];
    }
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.2 animations:^{
        self.datePickerBottomConstraint.constant = 0;
        self.setButtonBottomConstraint.constant = 162;
        [self.view layoutIfNeeded];
    }];
    
    self.startDateActive = NO;
    self.datePickerActive = YES;
}
- (IBAction)clearTimerPressed:(UIButton *)sender {
    
    self.startDate = nil;
    self.endDate = nil;
    
    self.startTimeLabel.text = @"-:-";
    self.endTimeLabel.text = @"-:-";
    
    self.textField.text = @"";
    
}

- (IBAction)redTapped:(UITapGestureRecognizer *)sender {
    [self refreshMyStatusUITo:Red_status];
}
- (IBAction)yellowTapped:(UITapGestureRecognizer *)sender {
    [self refreshMyStatusUITo:Yellow_status];
}
- (IBAction)greenTapped:(UITapGestureRecognizer *)sender {
    [self refreshMyStatusUITo:Green_status];
}

- (IBAction)setPressed:(UIButton *)sender {
    
    [self setItemsToVisible:NO];

    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.2 animations:^{
        self.datePickerBottomConstraint.constant = -162;
        self.textPickerBottomConstraint.constant = -162;
        self.setButtonBottomConstraint.constant = -204;
        [self.view layoutIfNeeded];
    }];
    
    if (self.datePickerActive) {
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"dd-MM·HH:mm"];
        
        if (self.startDateActive) {
            self.startDate = self.datePicker.date;
            
            if ([self.startDate compare:[NSDate date]] == NSOrderedDescending) {
                self.startTimeLabel.text =  [[dateFormater stringFromDate:self.startDate] uppercaseString];
            }else {
                self.startTimeLabel.text = @"-:-";
                self.startDate = nil;
            }
            
        }else {
            self.endDate = self.datePicker.date;
            
            if ([self.endDate compare:[NSDate date]] == NSOrderedDescending &&
                [self.endDate compare:self.startDate] == NSOrderedDescending) {
                self.endTimeLabel.text =  [[dateFormater stringFromDate:self.endDate] uppercaseString];
            }else {
                
                if (self.startDate) {
                    self.endDate = self.startDate;
                    self.endTimeLabel.text =  [[dateFormater stringFromDate:self.endDate] uppercaseString];
                }else {
                    self.endTimeLabel.text = @"-:-";
                    self.endDate = nil;
                }
                
               
            }
            
        }
    }else {
        self.textField.text = self.textArray[[self.textPicker selectedRowInComponent:0]];
    }

    
}
- (IBAction)cancelPressed:(id)sender {
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.2 animations:^{
        self.datePickerBottomConstraint.constant = -162;
        self.textPickerBottomConstraint.constant = -162;
        self.setButtonBottomConstraint.constant = -204;
        [self.view layoutIfNeeded];
    }];
    

    [self setItemsToVisible:NO];
    
}

- (IBAction)confirmButtonPressed:(UIButton *)sender {
    
    [SVProgressHUD show];
    
    Myuser *user = [Myuser sharedUser];
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    user.statusStartTime = @"2000-01-01T00:00:00";
    user.statusEndTime = @"2000-01-01T00:00:00";
    
    if (self.greenCircle.isHighlighted || (!self.startDate && !self.endDate)) {
        user.status = Green_status;
        if (self.redCircle.isHighlighted) {
            user.status = Red_status;
        }else if (self.yellowCircle.isHighlighted){
            user.status = Yellow_status;
        }
        
        user.statusText = self.textField.text;
        user.timerStatusText = @"";
        [[MyConnectionManager sharedManager]requestUpdateStatusWithDelegate:self selector:@selector(responseToUpdateStatus:)];
    }else {
        NSDate *currentDate = [NSDate date];
        
        if (!self.startDate || !self.endDate) {
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"Please correct you start and end time", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }else if ([self.startDate compare:currentDate] == NSOrderedAscending ||
                  [self.endDate compare:currentDate] == NSOrderedAscending ||
                  [self.startDate compare:self.endDate] != NSOrderedAscending) {
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"Please correct you start and end time", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }else {
            user.timerStatus = Green_status;
            if (self.redCircle.isHighlighted) {
                user.timerStatus = Red_status;
            }else if (self.yellowCircle.isHighlighted){
                user.timerStatus = Yellow_status;
            }
            user.timerStatusText = self.textField.text;
            user.statusStartTime = [[dateFormater stringFromDate:self.startDate] uppercaseString];
            user.statusEndTime = [[dateFormater stringFromDate:self.endDate] uppercaseString];
            [[MyConnectionManager sharedManager]requestUpdateStatusWithTimestampWithStatus:user.timerStatus delegate:self selector:@selector(responseToUpdateStatusWithTimestamp:)];
        }
    
    }
//    if (self.textField.text.length > 0 && ![self.textArray containsObject:self.textField.text]) {
//        [[DBManager sharedInstance]addDefaultTextToDefaultTextDb:self.textField.text];
//        [[MyConnectionManager sharedManager]requestSetDefaultTextsWithDelegate:self selector:nil];
//    }
    
    
}

//response methods
-(void)responseToUpdateStatusWithTimestamp:(NSDictionary *)dict{
    NSLog(@"responseToUpdateStatusWithTimestamp %@", dict);
    if (dict) {
        NSDictionary *pom1 = [[dict objectForKey:@"UpdateStatusWidthTimestampResponse"] objectForKey:@"UpdateStatusWidthTimestampResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
            [[SharedPreferences shared]saveUserData:[Myuser sharedUser]];
            [TimerNotification setTimerNotification];
            
             [self.navigationController popViewControllerAnimated:YES];
        }else {
            [self showErrorAlert];
        }
        
    }else {
        [self showErrorAlert];
    }
}
-(void)responseToUpdateStatus:(NSDictionary *)dict{
    NSLog(@"responseToUpdateStatus %@", dict);
    if (dict) {
        NSDictionary *pom1 = [[dict objectForKey:@"UpdateStatusResponse"] objectForKey:@"UpdateStatusResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
            [[SharedPreferences shared]saveUserData:[Myuser sharedUser]];
            
             [self.navigationController popViewControllerAnimated:YES];
        }else {
            [self showErrorAlert];
        }

    }else {
        [self showErrorAlert];
    }
}


//DELEGATE methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //limit the size :
    int limit = 40;
    return !([textField.text length]>limit && [string length] > range.length);
}

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return self.textArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return self.textArray[row];
}

@end
