//
//  SetLanguageTableViewController.m
//  CallAplication
//
//  Created by David Tomic on 25/11/15.
//  Copyright © 2015 David Tomic. All rights reserved.
//

#import "SetLanguageTableViewController.h"
#import "MyLanguage.h"
#import "AppDelegate.h"

@interface SetLanguageTableViewController ()

@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSArray *countryCodeArray;
@property (nonatomic) NSInteger selectedIndex;

@end

@implementation SetLanguageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.array = @[NSLocalizedString(@"English", nil), NSLocalizedString(@"Danish", nil)];
    self.countryCodeArray = @[NSLocalizedString(@"en", nil), NSLocalizedString(@"da", nil)];
    
    NSString *lCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
    
    if ([lCode isEqualToString:@"en"]) {
        self.selectedIndex = 0;
    }else if ([lCode isEqualToString:@"da"]){
        self.selectedIndex = 1;
    }

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = doneButton;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//my methods
-(void)doneButtonPressed:(UIBarButtonItem *)button {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    
    if (self.selectedIndex != selectedIndexPath.row) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:self.countryCodeArray[self.selectedIndex], nil] forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    NSLog(@"selectedIndexPath %d", selectedIndexPath.row);
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
    self.selectedIndex = indexPath.row;
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Language Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.array[indexPath.row];
    
    if(indexPath.row == self.selectedIndex)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}




@end
