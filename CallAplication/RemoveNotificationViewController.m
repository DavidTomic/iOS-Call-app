//
//  RemoveNotificationViewController.m
//  CallAplication
//
//  Created by David Tomic on 02/12/15.
//  Copyright © 2015 David Tomic. All rights reserved.
//

#import "RemoveNotificationViewController.h"
#import "DBManager.h"

@interface RemoveNotificationViewController ()
@property (nonatomic, strong) NSMutableArray *array;
@end

@implementation RemoveNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.array = [[DBManager sharedInstance]getAllNotificationsFromDb];
    
    NSLog(@"self.array %@", self.array);
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//my methods
-(void)doneButtonPressed:(UIBarButtonItem *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    Notification *notification = self.array[indexPath.row];
    [[DBManager sharedInstance] removeNotificationFromDbWithPhoneNumber:notification.phoneNumber];
    [self.array removeObjectAtIndex:indexPath.row];
    [tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Remove Notification Cell" forIndexPath:indexPath];
    
    Notification *notification = self.array[indexPath.row];
    
    cell.textLabel.text = notification.name;
   // cell.tintColor = [UIColor colorWithRed:(0.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    return cell;
}

@end
