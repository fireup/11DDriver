//
//  DDMyOrdersViewController.m
//  DDriver11
//
//  Created by ZBN on 14-7-13.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDMyOrdersViewController.h"
#import "DDMyOrderCell.h"
#import "AFNetworking/AFHTTPRequestOperationManager.h"
#import "DDOrderDetailViewController.h"
#import "DDDataHandler.h"

@interface DDMyOrdersViewController () <DDAFManagerDelegate> {
    DDAFManager *_manager;
}

@property (nonatomic, strong) NSArray *orders;

@end

@implementation DDMyOrdersViewController

- (void)getOrdersAndUpdateTableview
{
    
    [self.refreshControl beginRefreshing];
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSDictionary *parameters = @{@"request": @"getorderhistory",
                                 @"session_id" : [DDDataHandler sharedData].sessionID,
                                 @"client" : [DDDataHandler sharedData].appPlatform,
                                 @"version" : [DDDataHandler sharedData].appVersion};
    _manager = [[DDAFManager alloc] initWithURL:MYORDERSURL parameters:parameters delegate:self];
}

- (void)AFManagerDidFinishDownload:(NSDictionary *)responseObj forURL:(NSString *)URL
{
    if ([URL isEqualToString:MYORDERSURL]) {
        
//        responseObj = [DDDataHandler convertItemToString:responseObj];
        NSArray *ordersReceived = responseObj[@"orders"];
        NSMutableArray *orders = [[NSMutableArray alloc] init];
        
        for (NSDictionary *orderReceived in ordersReceived) {
            DDOrder *order = [[DDOrder alloc] init];
            order.isCurrent = [orderReceived[@"isCurrent"] boolValue];
            order.orderID = orderReceived[@"order_id"];
            order.bookTime = orderReceived[@"bookTime"];
            order.start = orderReceived[@"start_address_label"] ?  orderReceived[@"start_address_label"] : @"未指定";
            order.destination = orderReceived[@"end_address"] ? orderReceived[@"end_address"]: @"未指定";
            order.fare = orderReceived[@"subtotal"];
            order.otherInfo = [NSString stringWithFormat:@"等候费用：%@", orderReceived[@"waiting_charge"]];
            order.comment = orderReceived[@"comment"];
            order.rateStar = orderReceived[@"rateStar"];
            
            order.driver.driverID = orderReceived[@"driver_id"];
            order.driver.name = [orderReceived objectForKey:@"driver_name"];
            NSLog(@"%@",order.driver.name);
//            order.driver.comment = orderReceived[@"comment"];
            order.driver.phoneNO = orderReceived[@"mobile_working"];
//            order.driver.rateStar = orderReceived[@"rateStar"];
            order.driver.avatarURLTemp = orderReceived[@"avatarUrl"];
            order.driver.avatar = [UIImage imageNamed:@"driver_defaultavatar"];
            order.driver.jobCount = orderReceived[@"jobCount"];
            order.driver.delegate = self;
            
            [orders addObject:order];
        }
        self.orders = [NSArray arrayWithArray:orders];
        [self.refreshControl endRefreshing];
        
        _manager = nil;
    }
}

- (void)AFManagerDidFailedDownloadForURL:(NSString *)URL error:(NSString *)message
{
    [self.refreshControl endRefreshing];
    [DDDataHandler blankTitleAlert:message];
    _manager = nil;
}

- (void)AFManagerDidGetResultErrorForURL:(NSString *)URL error:(NSString *)message
{
    [self.refreshControl endRefreshing];
    [DDDataHandler blankTitleAlert:message];
    _manager = nil;
}


#pragma mark - tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.orders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OrderCell";
    DDMyOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    DDOrder *order = [self.orders objectAtIndex:indexPath.row];
    DDDriver *driver = order.driver;
    
    if (order.isCurrent) {
        cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.02];
    }
    cell.avatarView.image = driver.avatar;
    cell.nameLabel.text = driver.name;
    cell.nameLabel.text = driver.name;
    cell.rateStarLabel.text = order.rateStar;
    cell.bookTimeLabel.text = order.bookTime;
    cell.commentLabel.text = [NSString stringWithFormat:@"💬 %@",order.comment];
    
    //此时开始下载司机头像, 成功后通过delegate call更新.
    driver.avatarURL = driver.avatarURLTemp;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 94;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    [self performSegueWithIdentifier:@"OrderDetailVC" sender:self.orders[row]];
}

#pragma mark - driver delegate
//更新司机头像
- (void)didDownloadAvatarImageForDriver:(DDDriver *)driver
{
    for (DDOrder *order in self.orders) {
        if ([order.driver.driverID isEqualToString:driver.driverID]) {
            int i = [self.orders indexOfObject:order];
            DDMyOrderCell *cell = (DDMyOrderCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            cell.avatarView.image = driver.avatar;
        }
    }
}

#pragma mark -

- (void)setOrders:(NSArray *)orders
{
    _orders = orders;
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINib *nib = [UINib nibWithNibName:@"DDMyOrderCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"OrderCell"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getOrdersAndUpdateTableview) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor lightGrayColor];

    [self getOrdersAndUpdateTableview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getOrdersAndUpdateTableview];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"OrderDetailVC"]) {
        if ([segue.destinationViewController isKindOfClass:[DDOrderDetailViewController class]]) {
            DDOrderDetailViewController *odvc = (DDOrderDetailViewController *)segue.destinationViewController;
            odvc.order = (DDOrder *)sender;
        }
    }
}


@end
