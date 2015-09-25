//
//  SettingsViewController.m
//  CallAplication
//
//  Created by David Tomic on 27/07/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsDetailViewController.h"
#import "Myuser.h"

@interface SettingsViewController()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *tableArray;
@property (strong, nonatomic) Myuser *user;

@end

@implementation SettingsViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Settings", nil);
    self.user = [Myuser sharedUser];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(NSArray *)tableArray{
    
    if (!_tableArray) {
        _tableArray = @[NSLocalizedString(@"Set Language", nil), NSLocalizedString(@"Phone number", nil), NSLocalizedString(@"Password", nil), NSLocalizedString(@"Name", nil), NSLocalizedString(@"Email", nil), NSLocalizedString(@"Default text", nil),NSLocalizedString(@"Set status", nil), NSLocalizedString(@"Edit notification", nil)];
    }
    
    return _tableArray;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.tableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SettingsCell"];
    }
    
    cell.textLabel.text = self.tableArray[indexPath.row];
    
    if (indexPath.row > 5) {
        cell.detailTextLabel.text = @"";
    }else {
        
        NSString *statusText = self.user.statusText != nil ? self.user.statusText : @"";
        NSString *name = self.user.name != nil ? self.user.name : @"";
        NSString *email = self.user.email != nil ? self.user.email : @"";
        NSString *language = self.user.language == English ? NSLocalizedString(@"English", nil) : NSLocalizedString(@"Danish", nil);
        
        cell.detailTextLabel.text = @[language, self.user.phoneNumber, @"******", name, email, statusText][indexPath.row];
    }
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.tableArray[indexPath.row] isEqualToString:NSLocalizedString(@"Default text", nil)]) {
            [self performSegueWithIdentifier:@"Default Text Segue" sender:tableView];
    } else if ([self.tableArray[indexPath.row] isEqualToString:NSLocalizedString(@"Edit notification", nil)]){
        
    } else if ([self.tableArray[indexPath.row] isEqualToString:NSLocalizedString(@"Set status", nil)]){
            [self performSegueWithIdentifier:@"Set Status Segue" sender:tableView];
    }  else {
            [self performSegueWithIdentifier:@"Settings Detail Segue" sender:tableView];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"Settings Detail Segue"]) {
        SettingsDetailViewController *sdvc = segue.destinationViewController;
        sdvc.item = self.tableArray[[self.tableView indexPathForSelectedRow].row];
    }
}

@end
