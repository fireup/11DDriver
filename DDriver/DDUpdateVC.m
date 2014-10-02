//
//  DDUpdateVC.m
//  DDriver
//
//  Created by ZBN on 14-9-6.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDUpdateVC.h"

@interface DDUpdateVC () <DDAFManagerDelegate, UIAlertViewDelegate>{
    DDAFManager *_manager;
    NSString *_updateURL;
}

@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;

@end

@implementation DDUpdateVC

- (void)checkUpdate
{
    UIActivityIndicatorView *iView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-10, self.view.bounds.size.height/2-10, 20, 20)];
    iView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    iView.tag = 10;
    [iView startAnimating];
    [self.view addSubview:iView];
    
    NSDictionary *para = @{@"request": @"checkupdate",
                           @"client": [DDDataHandler sharedData].appPlatform,
                           @"version": [DDDataHandler sharedData].appVersion};
    
    _manager = [[DDAFManager alloc] initWithURL:UPDATEURL parameters:para delegate:self];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *str = @"当前版本：";
    NSString *str2 = [str stringByAppendingString:[DDDataHandler sharedData].appVersion];
    self.currentLabel.text = str2;
    self.updateButton.hidden = YES;
    
    [self checkUpdate];
}

- (void)AFManagerDidFinishDownload:(NSDictionary *)responseObj forURL:(NSString *)URL
{
    [[self.view viewWithTag:10]removeFromSuperview];
    self.updateButton.hidden = NO;
    _manager = nil;
    NSString *version = responseObj[@"currentversion"];
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), version);
    if ([version intValue] > [[DDDataHandler sharedData].appVersion intValue]) {
        _updateURL = responseObj[@"updateurl"];
        UIAlertView *aView = [[UIAlertView alloc] initWithTitle:nil message:@"有新版本可用！" delegate:self cancelButtonTitle:@"以后再说" otherButtonTitles:@"去更新", nil];
        [aView show];
    } else {
        UIAlertView *aView = [[UIAlertView alloc] initWithTitle:nil message:@"当前版本为最新" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [aView show];
    }
}

- (void)AFManagerDidFailedDownloadForURL:(NSString *)URL error:(NSString *)message
{
    [[self.view viewWithTag:10]removeFromSuperview];
    self.updateButton.hidden = NO;
    _manager = nil;
    [DDDataHandler blankTitleAlert:message];
}

- (void)AFManagerDidGetResultErrorForURL:(NSString *)URL error:(NSString *)message
{
    [self AFManagerDidFailedDownloadForURL:URL error:message];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView firstOtherButtonIndex]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_updateURL]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
