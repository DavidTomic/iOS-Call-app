//
//  DefaultTextViewController.m
//  CallAplication
//
//  Created by David Tomic on 25/09/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "DefaultTextViewController.h"
#import "DBManager.h"
#import "SettingsDetailViewController.h"
#import "MyConnectionManager.h"

@interface DefaultTextViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *tableArray;
@end

@implementation DefaultTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", nil) style:UIBarButtonItemStylePlain target:self action:@selector(addButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
}

-(void)viewWillAppear:(BOOL)animated{
    self.tableArray = nil;
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *)tableArray{
    
    if (!_tableArray) {
        _tableArray = [NSMutableArray arrayWithArray:[[DBManager sharedInstance]getAllDefaultTextsFromDb]];
    }
    
    return _tableArray;
}

-(void)addButtonPressed:(UIBarButtonItem *)button{
    [self performSegueWithIdentifier:@"Settings Detail Segue" sender:button];
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
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DefaultCell"];
    }
    
    cell.textLabel.text = [self.tableArray[indexPath.row] objectForKey:@"text"];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Settings Detail Segue" sender:tableView];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    [[DBManager sharedInstance]removeDefaultTextFromDefaultTextDb:[[self.tableArray[indexPath.row] objectForKey:@"id"] integerValue]];
    [self.tableArray removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [[MyConnectionManager sharedManager]requestSetDefaultTextsWithDelegate:self selector:nil];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Settings Detail Segue"]) {
        
        SettingsDetailViewController *sdvc = segue.destinationViewController;
        
        if ([sender isKindOfClass:[UIBarButtonItem class]]) {
            sdvc.item = NSLocalizedString(@"Add new default text", nil);
        }else{
            sdvc.editDefaultText = YES;
            sdvc.item = [self.tableArray[[self.tableView indexPathForSelectedRow].row] objectForKey:@"text"];
            sdvc.textId = [[self.tableArray[[self.tableView indexPathForSelectedRow].row] objectForKey:@"id"] integerValue];
        }
    }
}


@end
