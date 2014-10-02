//
//  DDLeftViewController.m
//  DDriver11
//
//  Created by ZBN on 14-6-30.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDLeftViewController.h"
#import "DDLoginViewController.h"
#import "DDUserDetailViewController.h"

@interface DDLeftViewController ()

@end

@implementation DDLeftViewController


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *path;
    //Logincell and feedbackcell require user login.
    BOOL isLogin = [DDDataHandler sharedData].isLogin;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *identifier = cell.reuseIdentifier;
    
    if ((!isLogin) && ([identifier isEqualToString:@"LoginCell"] || [identifier isEqualToString:@"FeedbackCell"])) {
        
        DDLoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
        self.view.window.rootViewController.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
        loginVC.dismissBlock = ^{
            [self.tableView reloadData];
        };
        UINavigationController *nVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:nVC animated:YES completion:nil];
        
        path = nil;
        
    } else if ([identifier isEqualToString:@"ServiceLine"]) {
        
        UIDevice *device = [UIDevice currentDevice];
        if ([[device model] isEqualToString:@"iPhone"] ) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:4008009987"]]];
        } else {
            UIAlertView *notPermitted=[[UIAlertView alloc] initWithTitle:@"无法拨打" message:@"您的设备无法拨打电话" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [notPermitted show];
        }
        
        path = nil;
        
    } else {
        path = indexPath;
    }
    return path;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    [self.tableView reloadData];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.textLabel.text = [DDDataHandler sharedData].isLogin ? [DDDataHandler sharedData].phoneNO : @"使用手机号登录";
    
    self.mm_drawerController.maximumLeftDrawerWidth = 280;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    self.mm_drawerController.maximumLeftDrawerWidth = 320;

}


@end
