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

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@property (strong, nonatomic) NSMutableArray *textArray;

@property (nonatomic) BOOL datePickerActive;
@property (nonatomic) BOOL startDateActive;

@end

@implementation SetStatusViewController

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

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            
            self.iAmLabel.text = NSLocalizedString(@"I'm busy from:", nil);
            
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
            
            self.iAmLabel.text = NSLocalizedString(@"I'm away from:", nil);
            
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
            break;
    }
}
-(void)setItemsToVisible:(BOOL)visible{
    self.confirmButton.hidden = visible;
    self.startTimeButton.hidden = visible;
    self.iAmLabel.hidden = visible;
    self.startTimeLabel.hidden = visible;
    self.startTimeButton.hidden = visible;
    self.iamOnlineLabel.hidden = visible;
    self.endTimeLabel.hidden = visible;
    self.endTimeButton.hidden = visible;
}

//response methods
-(void)responseToUpdateStatusWithTimestamp:(NSDictionary *)dict{
    NSLog(@"responseToUpdateStatusWithTimestamp %@", dict);
    if (dict) {
        NSDictionary *pom1 = [[dict objectForKey:@"UpdateStatusWidthTimestampResponse"] objectForKey:@"UpdateStatusWidthTimestampResult"];
        
        if ([[pom1 objectForKey:@"Result"] integerValue] == 2) {
            [[SharedPreferences shared]saveUserData:[Myuser sharedUser]];
        }
        
    }
}


- (IBAction)selectTextPressed:(UIButton *)sender {
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

    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.4 animations:^{
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

    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.4 animations:^{
        self.datePickerBottomConstraint.constant = 0;
        self.setButtonBottomConstraint.constant = 162;
        [self.view layoutIfNeeded];
    }];
    
    self.startDateActive = NO;
    self.datePickerActive = YES;
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
        [dateFormater setDateFormat:@"HH:mm"];
        
        if (self.startDateActive) {
            self.startDate = self.datePicker.date;
            
            if ([self.startDate compare:[NSDate date]] == NSOrderedDescending) {
                self.startTimeLabel.text =  [[dateFormater stringFromDate:self.startDate] uppercaseString];
            }else {
                self.startTimeLabel.text = NSLocalizedString(@"Now", nil);
                self.startDate = nil;
            }
            
        }else {
            self.endDate = self.datePicker.date;
            
            if ([self.endDate compare:[NSDate date]] == NSOrderedDescending) {
                self.endTimeLabel.text =  [[dateFormater stringFromDate:self.endDate] uppercaseString];
            }else {
                self.endTimeLabel.text = NSLocalizedString(@"Now", nil);
                self.endDate = nil;
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
    
    Myuser *user = [Myuser sharedUser];
    
    Status status = Green_status;
    
    if (self.redCircle.isHighlighted) {
        status = Red_status;
    }else if (self.yellowCircle.isHighlighted){
        status = Yellow_status;
    }else {
        user.status = status;
    }
    
    user.statusText = self.textField.text;
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    user.statusStartTime = @"2000-01-01T00:00:00";
    user.statusEndTime = @"2000-01-01T00:00:00";
    
    NSDate *currentDate = [NSDate date];
   // NSLog(@"currentDate %@", [[dateFormater stringFromDate:currentDate] uppercaseString]);

    if (self.startDate && [self.startDate compare:currentDate] == NSOrderedDescending) {
        user.statusStartTime = [[dateFormater stringFromDate:self.startDate] uppercaseString];
    }
    
    if (self.endDate && [self.endDate compare:currentDate] == NSOrderedDescending) {
        user.statusEndTime = [[dateFormater stringFromDate:self.endDate] uppercaseString];
    }
    
    NSLog(@"startDate %@", user.statusStartTime);
    NSLog(@"endDate %@", user.statusEndTime);
    
    
    [[MyConnectionManager sharedManager]requestUpdateStatusWithTimestampWithStatus:status delegate:self selector:@selector(responseToUpdateStatusWithTimestamp:)];
    
    if (self.textField.text.length > 0 && ![self.textArray containsObject:self.textField.text]) {
        [[DBManager sharedInstance]addDefaultTextToDefaultTextDb:self.textField.text];
        [[MyConnectionManager sharedManager]requestSetDefaultTextsWithDelegate:self selector:nil];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
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
