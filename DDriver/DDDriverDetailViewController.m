//
//  DDDriverDetailViewController.m
//  DDriver11
//
//  Created by ZBN on 14-7-10.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DDDriverDetailViewController.h"
#import "DDDriver.h"
#import "DDAFManager.h"
#import "DDDriverInfoView.h"
#import "DDLoginViewController.h"
#import "DDDataHandler.h"


@interface DDDriverDetailViewController () <DDAFManagerDelegate> {
    DDAFManager *_manager;
}

@property (weak, nonatomic) IBOutlet UIView *addtionalDriverInfoView;

@property (weak, nonatomic) IBOutlet UIScrollView *commentView;

@end

@implementation DDDriverDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CALayer *layer = self.addtionalDriverInfoView.layer;
    layer.shadowOffset = CGSizeMake(0, 2.0);
    layer.shadowColor = [[UIColor grayColor] CGColor];
    layer.shadowRadius = 1.0f;
    layer.shadowOpacity = 0.80f;
    layer.shadowPath = [[UIBezierPath bezierPathWithRect:layer.bounds] CGPath];
    
    DDDriverInfoView *dView = [[DDDriverInfoView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 140)];
    
    dView.nameLabel.text = self.driver.name;
    dView.rateStarLabel.text = self.driver.rateStar;
    
    dView.jobCountsLabel.text = [NSString stringWithFormat:@"代驾 %@ 次", self.driver.jobCount];
    dView.distanceLabel.text = self.driver.distanceInKM ? [NSString stringWithFormat:@"%.2f公里",self.driver.distanceInKM] : @"";
    dView.avatarView.image = self.driver.avatar;
    
    [self.view addSubview:dView];
    
    NSDictionary *parameters = @{@"request" : @"comment",
                                 @"driverid" : self.driver.driverID,
                                 @"session_id" : [DDDataHandler sharedData].sessionID,
                                 @"client" : [DDDataHandler sharedData].appPlatform,
                                 @"version" : [DDDataHandler sharedData].appVersion};
    _manager = [[DDAFManager alloc] initWithURL:DRIVERCOMMENTURL parameters:parameters delegate:self];
}

- (void)AFManagerDidFinishDownload:(NSDictionary *)responseObj forURL:(NSString *)URL
{
    NSArray *coms = responseObj[@"list"];
    int count = [coms count];
    CGRect frame = self.commentView.frame;
    if (frame.size.height < 60*count) {
        frame.size.height = 60*count;
        self.commentView.contentSize = CGSizeMake(frame.size.width, 60*count);
    }
    
    for (int i=0; i<count; i++) {
        UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(0, 60*i, self.view.bounds.size.width, 60)];
        
        UIImageView *phoneView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 9, 13)];
        phoneView.image = [UIImage imageNamed:@"dView_phone"];
        [cView addSubview:phoneView];
        
        NSDictionary *com = coms[i];
        UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 15, 140, 13)];
        userLabel.text = com[@"user"];
        userLabel.font = [UIFont systemFontOfSize:11];
        [cView addSubview:userLabel];
        
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 38, 280, 13)];
        commentLabel.text = com[@"comment"];
        commentLabel.font = [UIFont systemFontOfSize:11];
        [cView addSubview:commentLabel];
        
        NSMutableString *rateStar = [NSMutableString stringWithFormat:@""];
        for (int i=0; i<[com[@"ratestar"] intValue]; i++) { [rateStar appendString:@"⭐️"]; }
        UILabel *rateStarLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 15, 120, 13)];
        rateStarLabel.text = [NSString stringWithFormat:@"评价：%@",rateStar];
        rateStarLabel.font = [UIFont systemFontOfSize:11];
        [cView addSubview:rateStarLabel];
        
        UILabel *upperLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cView.bounds.size.width, 0.5)];
        upperLine.backgroundColor = [UIColor lightGrayColor];
        [cView addSubview:upperLine];
        
        [self.commentView addSubview:cView];
        [self.view sendSubviewToBack:self.commentView];
    }
}

- (void)AFManagerDidFailedDownloadForURL:(NSString *)URL error:(NSString *)message
{
    _manager = nil;
}

- (void)AFManagerDidGetResultErrorForURL:(NSString *)URL error:(NSString *)message
{
    _manager = nil;
}


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"FromDriverTo1Click"]) {
        //判断是否用户已登录
        if (![DDDataHandler sharedData].isLogin) {
            DDLoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
            self.view.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
            loginVC.dismissBlock = ^{
                [self performSegueWithIdentifier:@"FromDriverTo1Click" sender:self];
            };
            UINavigationController *nVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [self presentViewController:nVC animated:YES completion:nil];
            return NO;
        } else {
            return YES;
        }
    } else {
        return YES;
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
