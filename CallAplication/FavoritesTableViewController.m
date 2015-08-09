//
//  FavoritesTableViewController.m
//  CallAplication
//
//  Created by David Tomic on 27/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import "DBManager.h"
#import "Myuser.h"
#import "Contact.h"
#import "FavoritTableViewCell.h"
#import "ContactDetailViewController.h"


@interface FavoritesTableViewController()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *favoritContacts;
@property (nonatomic, strong) UIView *navView;

@end

@implementation FavoritesTableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
  //  self.navigationController.navigationBar.barTintColor = [UIColor redColor];
  //  self.navigationController.navigationBar.hidden = YES;
    
  //  NSString * s = NSLocalizedString(@"TEST_STRING", @"");
 //   NSLog(@"string: %@", s);
    
    float navViewHeight = 43;
    self.navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, navViewHeight)];
    
    UIView *circle = [[UIView alloc]initWithFrame:CGRectMake(10, navViewHeight/2-5, 10, 10)];
    circle.backgroundColor = [UIColor greenColor];
    circle.layer.cornerRadius = circle.frame.size.width / 2;
    circle.layer.borderWidth = 0;
    circle.clipsToBounds = YES;
    [self.navView addSubview:circle];
    
    UILabel *statusLabel = [[UILabel alloc]init];
    statusLabel.text = @"This is my status..";
    statusLabel.textColor = [UIColor lightGrayColor];
    [statusLabel setFont:[statusLabel.font fontWithSize:10]];
    [statusLabel sizeToFit];
    statusLabel.frame = CGRectMake(10, navViewHeight-statusLabel.frame.size.height-2, statusLabel.frame.size.width, statusLabel.frame.size.height);
    [self.navView addSubview:statusLabel];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(statusTapped:)];
    [self.navView addGestureRecognizer:tapRecognizer];
    
    [self.navigationController.navigationBar addSubview:self.navView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveContactListReloadedNotification:)
                                                 name:@"ContactListReloaded"
                                               object:nil];
    
}

-(NSMutableArray *)favoritContacts{
    
    if (!_favoritContacts) _favoritContacts = [[NSMutableArray alloc]init];
    return _favoritContacts;
}

-(void)receiveContactListReloadedNotification:(NSNotification *)notification{
//    NSLog(@"receiveContactListReloadedNotification");
//    NSLog(@"COUNT %lu", (unsigned long)[Myuser sharedUser].contactDictionary.count);
    [self reloadData];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadData];
//    NSArray *tables = [[DBManager sharedInstance]getTableList];
//    NSLog(@"tables %@", tables);
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navView.hidden = YES;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navView.hidden = NO;
}

-(void)reloadData{
    NSArray *contactArray = [[Myuser sharedUser].contactDictionary allValues];
    self.favoritContacts = nil;
    
    for (NSArray *array in contactArray){
        for (Contact *contact in array){
            if (contact.favorit) {
                [self.favoritContacts addObject:contact];
            }
        }
    }
    
   // NSLog(@"favoritContacts %@", self.favoritContacts);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
-(void)statusTapped:(UITapGestureRecognizer *)tapRecognizer{
    NSLog(@"status tapped");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"COUNT %d", [self.favoritContacts count]);
    return [self.favoritContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FavoritTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[FavoritTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    Contact *contact = self.favoritContacts[indexPath.row];
    
    UIImage *img2 = contact.image;
    
    if (img2.size.width > 0 && img2.size.height > 0) {
        [cell.image setImage:img2 forState:UIControlStateNormal];
        [cell.image setBackgroundColor:[UIColor clearColor]];
    }else {
        [cell.image setImage:nil forState:UIControlStateNormal];
        NSString *text = [[contact.firstName substringToIndex:1] uppercaseString];
        if (contact.lastName) {
            text = [NSString stringWithFormat:@"%@%@", text, [[contact.lastName substringToIndex:1] uppercaseString]];
        }
        [cell.image setBackgroundColor:[UIColor grayColor]];
        [cell.image setTitle:text forState:UIControlStateNormal];
    }
    
    NSString *text = contact.firstName;
    if (contact.lastName) {
        text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
    }
    
    cell.nameLabel.text = text;
    cell.statusTextLabel.text = @"hello this is my status";
    
    
    switch (contact.status) {
        case 0:
            [cell.status setBackgroundColor:[UIColor grayColor]];
            break;
        case 1:
            [cell.status setBackgroundColor:[UIColor redColor]];
            break;
        case 2:
            [cell.status setBackgroundColor:[UIColor yellowColor]];
            break;
        case 3:
            [cell.status setBackgroundColor:[UIColor greenColor]];
            break;
            
        default:
            [cell.status setBackgroundColor:[UIColor grayColor]];
            break;
    }
    
//    [cell.info addTarget:self action:@selector(infoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"didSelectRowAtIndexPath");
    Contact *contact = self.favoritContacts[indexPath.row];
    NSString *phoneNumber = contact.phoneNumber;
    
    //NSLog(@"makeCall");
    if (phoneNumber) {
        phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet] componentsJoinedByString:@""];
        // NSLog(@"phoneNumberA %@", phoneNumber);
        
        [Myuser sharedUser].lastDialedRecordId = contact.recordId;
        
        NSString *pNumber = [@"telprompt://" stringByAppendingString:phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pNumber]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"commitEditingStyle");
    Contact *contact = self.favoritContacts[indexPath.row];
    contact.favorit = NO;
    
    [[DBManager sharedInstance]addOrRemoveContactInFavoritWithRecordId:contact.recordId];
    
    
    [self.favoritContacts removeObjectAtIndex:indexPath.row];
    
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

//-(void)infoButtonTapped:(UIButton *)button{
//    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.tableView];
//    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
//    if (indexPath != nil)
//    {
//        NSLog(@"index %d", indexPath.row);
//    }
//}

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    if(self.editing)
    {
        [super setEditing:NO animated:NO];
        [self.tableView setEditing:NO animated:NO];
        [self.tableView reloadData];
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
    }
    else
    {
        [super setEditing:YES animated:YES];
        [self.tableView setEditing:YES animated:YES];
        [self.tableView reloadData];
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
        [self reloadData];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([sender isKindOfClass:[UIButton class]]){
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        if(indexPath){
            if([[segue identifier]isEqualToString:@"Contact Detail Segue From Favorites"]){
                if([segue.destinationViewController isKindOfClass:[ContactDetailViewController class]]){
                    
                    Contact *contact = self.favoritContacts[indexPath.row];
                    ContactDetailViewController *vc = (ContactDetailViewController *)segue.destinationViewController;
                    vc.contact = contact;
                }
            }
        }
    }
}

@end
