//
//  DDMainViewController.m
//  DDriver11
//
//  Created by ZBN on 14-6-30.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDMainViewController.h"
#import "DDLoginViewController.h"
#import "DDDataHandler.h"

@interface DDMainViewController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *mainMenuButtons;

@end

@implementation DDMainViewController


- (IBAction)mainMenuButtonPressed:(UIButton *)sender
{
    
    NSString *identifier;
    switch ([self.mainMenuButtons indexOfObject:sender])
    {
        case 0:
            identifier = @"NearBySegue";
            break;
        case 1:
            //判断是否用户已登录
            if (![DDDataHandler sharedData].isLogin) {
                [self presentLoginVCWithDismissBlock:^{
                    [self mainMenuButtonPressed:self.mainMenuButtons[1]];
                }];
                return;
            } else {
                identifier = @"FromMainTo1Click";
            }
            break;
        case 2:
            if (![DDDataHandler sharedData].isLogin) {
                [self presentLoginVCWithDismissBlock:^{
                    [self mainMenuButtonPressed:self.mainMenuButtons[2]];
                }];
                return;
            } else {
                identifier = @"MyOrdersSegue";
            }
            break;
        case 3:
            identifier = @"PriceListSegue";
            break;
        case 4:
            identifier = @"AboutUsSegue";
            break;
        case 5:
            identifier = @"ShareSegue";
            break;
        default:
            identifier = @"";
            break;
    }
    sender.highlighted = NO;
    [self performSegueWithIdentifier:identifier sender:self];
    
}
- (IBAction)toggleDrawer:(UIBarButtonItem *)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)mainMenuButtonTouchDown:(UIButton *)sender
{
    for (UIButton *button in self.mainMenuButtons){
        if (button.highlighted == YES && button != sender) {
            [button cancelTrackingWithEvent:UIEventTypeTouches];
        }
    }
    sender.highlighted = YES;
}

- (void)presentLoginVCWithDismissBlock:(void (^)(void))dismissBlock
{
    DDLoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    loginVC.dismissBlock = dismissBlock;
    UINavigationController *nVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self presentViewController:nVC animated:YES completion:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"naviTitle"]];
    for (UIButton *button in self.mainMenuButtons) {
        [button setBackgroundImage:[UIImage imageNamed:@"mainButtonBG"] forState: UIControlStateHighlighted];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"launched"]) {
        
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        CGRect screenRect = window.bounds;
        CGRect bigRect = screenRect;
        bigRect.size.width *= 4.0;
        
        UIView *bigView = [[UIView alloc] initWithFrame:bigRect];
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:screenRect];
        scrollView.tag = 10;
        scrollView.contentSize = bigRect.size;
        scrollView.pagingEnabled = YES;
        
        for (int i=0; i<4; i++) {
            CGRect imageRect = screenRect;
            imageRect.origin.x += imageRect.size.width * i;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageRect];
            imageView.image = [UIImage imageNamed:[@"help" stringByAppendingString:[NSString stringWithFormat:@"%i", i+1]]];
            
            [bigView addSubview:imageView];
            
            if (i == 3) {
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(bigView.bounds.size.width-100, bigView.bounds.size.height-50, 80, 30)];
                [button setTitle:@"立即体验" forState:UIControlStateNormal];
                [button addTarget:self action:@selector(disableIntro:) forControlEvents:UIControlEventTouchUpInside];
                [bigView addSubview:button];
                
            }
        }
        [scrollView addSubview:bigView];
        [window addSubview:scrollView];
    }
}

- (void)disableIntro:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"launched"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [UIView animateWithDuration:1.0
                     animations:^{
                         [window viewWithTag:10].alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [[window viewWithTag:10] removeFromSuperview];
                     }];
}

#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}


@end
