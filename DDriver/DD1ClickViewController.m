//
//  DD1ClickViewController.m
//  DDriver11
//
//  Created by ZBN on 14-7-11.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DD1ClickViewController.h"
#import "DDDriver.h"
#import "CMPopTipView.h"
#import "DDLoginViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "DDDataHandler.h"

@interface DD1ClickViewController () <CMPopTipViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, DDAFManagerDelegate> {
    DDAFManager *_manager;
}

@property (weak, nonatomic) IBOutlet UILabel *numberOfDrivers;
@property (weak, nonatomic) IBOutlet UIButton *phoneNumberButton;
@property (weak, nonatomic) CMPopTipView *roundRectButtonPopTipView;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;
@property (weak, nonatomic) IBOutlet UIButton *orderButton;


@end

@implementation DD1ClickViewController

- (IBAction)increaseNumberOfDrivers:(id)sender
{
    int number = [self.numberOfDrivers.text intValue] < 4 ? [self.numberOfDrivers.text intValue] + 1 : [self.numberOfDrivers.text intValue];
    self.numberOfDrivers.text = [NSString stringWithFormat:@"%d",number];
}

- (IBAction)decreaseNumberOfDrivers:(id)sender
{
    int currentNumber = [self.numberOfDrivers.text intValue];
    int number = (currentNumber > 1) ? (currentNumber - 1) : currentNumber;
    self.numberOfDrivers.text = [NSString stringWithFormat:@"%d", number];
}


- (IBAction)changeAddress:(UIButton *)sender
{
    NSString *title1, *title2, *title3;
    
    title1 = ([DDDataHandler sharedData].defaultLoc)[@"address"] ? [@"默认地址：" stringByAppendingString: ([DDDataHandler sharedData].defaultLoc)[@"address"]] : @"选择默认地址";
    title2 = [DDDataHandler sharedData].customAddress ? [@"自定地址：" stringByAppendingString: [DDDataHandler sharedData].customAddress] : @"选择自定地址";
    title3 = [DDDataHandler sharedData].currentAddress ? [@"当前地址：" stringByAppendingString: [DDDataHandler sharedData].currentAddress] : @"定位当前地址";
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"更改联系地址"
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:title1,title2,title3, nil];
    [action showInView:self.view];
}

- (IBAction)placeOrder:(UIButton *)sender
{
    if (![DDDataHandler sharedData].customLocation && ![DDDataHandler sharedData].currentLocation) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法提交订单" message:@"请定位当前位置，或手动选择位置" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if ([DDDataHandler sharedData].isLogin) {
        

        NSDictionary *para, *startLoc;
        if ([DDDataHandler sharedData].customAddress) {
            startLoc = @{@"address": [DDDataHandler sharedData].customAddress,
                                       @"latitude" : [NSString stringWithFormat:@"%f", [DDDataHandler sharedData].customLocation.coordinate.latitude],
                                       @"longitude" : [NSString stringWithFormat:@"%f", [DDDataHandler sharedData].customLocation.coordinate.longitude]};
        } else {
            startLoc = @{@"address": [DDDataHandler sharedData].currentAddress,
                        @"latitude" : [NSString stringWithFormat:@"%f", [DDDataHandler sharedData].currentLocation.coordinate.latitude],
                        @"longitude" : [NSString stringWithFormat:@"%f", [DDDataHandler sharedData].currentLocation.coordinate.longitude]};
        }
        
        para = @{@"request": @"orderalldriver",
                 @"session_id" : [DDDataHandler sharedData].sessionID,
                 @"contactphoneno" : [DDDataHandler sharedData].phoneNO,
                 @"amount" : self.numberOfDrivers.text,
                 @"startloc" : startLoc,
                 @"client" : [DDDataHandler sharedData].appPlatform,
                 @"version" : [DDDataHandler sharedData].appVersion};
        
        _manager = [[DDAFManager alloc] initWithURL:PLACEORDERALLDRIVERSURL parameters:para delegate:self];
        
    } else {
        DDLoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
        self.view.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        loginVC.dismissBlock = ^{
            [self performSelector:@selector(placeOrder:) withObject:nil];
        };
        [self presentViewController:loginVC animated:YES completion:nil];
    }
    
}

- (void)AFManagerDidFinishDownload:(NSDictionary *)responseObj forURL:(NSString *)URL
{
    if ([URL isEqualToString:PLACEORDERALLDRIVERSURL]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下单成功" message:@"请稍候，司机将很快与您联系" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        _manager = nil;
    }
}

- (void)AFManagerDidFailedDownloadForURL:(NSString *)URL error:(NSString *)message
{
    [DDDataHandler blankTitleAlert:message];
    _manager = nil;
}

- (void)AFManagerDidGetResultErrorForURL:(NSString *)URL error:(NSString *)message
{
    [DDDataHandler blankTitleAlert:message];
    _manager = nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.numberOfDrivers.layer.borderColor = [UIColor colorWithRed:(101/255.0) green:(192/255.0) blue:(195/255.0) alpha:1.0].CGColor;
    self.numberOfDrivers.layer.borderWidth = 2.0;
    
    //init phonenumber button
    self.phoneNumberButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.phoneNumberButton.layer.borderWidth = 0.5;
    self.phoneNumberButton.layer.cornerRadius = 10.0;
    UIImageView *phoneView = [[UIImageView alloc] initWithFrame:CGRectMake(15 , 15, 9, 13)];
    phoneView.image = [UIImage imageNamed:@"dView_phone"];
    [self.phoneNumberButton addSubview:phoneView];
    
    //init address button
    self.addressButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.addressButton.layer.borderWidth = 0.5;
    self.addressButton.layer.cornerRadius = 10.0;
//    self.addressButton.titleLabel.frame = CGRectMake(30, 12, self.addressButton.bounds.size.width-30-32, 20);
    UIImageView *pinView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 9, 13)];
    pinView.image = [UIImage imageNamed:@"1click_addresspin"];
    UIImageView *disView = [[UIImageView alloc] initWithFrame:CGRectMake(self.addressButton.bounds.size.width-22, 17, 12, 12)];
    disView.image = [UIImage imageNamed:@"disclosure"];
    [self.addressButton addSubview:pinView];
    [self.addressButton addSubview:disView];
}

- (void)updateTitleOfButton:(UIButton *)button withString:(NSString *)string
{
    NSMutableAttributedString *newAttrStr = [[NSMutableAttributedString alloc] initWithString:string];
    [newAttrStr addAttribute:NSForegroundColorAttributeName
                       value:[UIColor blackColor]
                       range:NSMakeRange(5, newAttrStr.length-5)];
    [newAttrStr addAttribute:NSForegroundColorAttributeName
                       value:[UIColor colorWithRed:0.040854 green:0.374803 blue:0.998358 alpha:1.0]
                       range:NSMakeRange(0, 5)];
    [button setAttributedTitle:newAttrStr forState:UIControlStateNormal];
    [button setAttributedTitle:newAttrStr forState:UIControlStateHighlighted];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if ([DDDataHandler sharedData].isLogin) {
        NSString *str = @"联系电话：";
        NSString *newStr = [str stringByAppendingString:[DDDataHandler sharedData].phoneNO];
        [self updateTitleOfButton:self.phoneNumberButton withString:newStr];
    }
    if (([DDDataHandler sharedData].defaultLoc)[@"address"]) {
        NSString *newStr = [@"默认地址：" stringByAppendingString: ([DDDataHandler sharedData].defaultLoc)[@"address"]];
        [self updateTitleOfButton:self.addressButton withString:newStr];
        
    } else if ([DDDataHandler sharedData].customAddress) {
        NSString *newStr = [@"自定地址：" stringByAppendingString: [DDDataHandler sharedData].customAddress];
        [self updateTitleOfButton:self.addressButton withString:newStr];
        
    } else if ([DDDataHandler sharedData].currentAddress) {
        NSString *newStr = [@"当前地址：" stringByAppendingString: [DDDataHandler sharedData].currentAddress];
        [self updateTitleOfButton:self.addressButton withString:newStr];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法获取地址"
                                                        message:@"请定位当前位置，或手动设置"
                                                       delegate:nil
                                              cancelButtonTitle:@"确认"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - actionsheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) { return; }
	switch (buttonIndex) {
		case 0:
		{
            if (([DDDataHandler sharedData].defaultLoc)[@"address"]) {
                NSString *newStr = [@"默认地址：" stringByAppendingString: ([DDDataHandler sharedData].defaultLoc)[@"address"]];
                [self updateTitleOfButton:self.addressButton withString:newStr];
            }
			break;
		}
		case 1:
		{
            if ([DDDataHandler sharedData].customAddress) {
                NSString *newStr = [@"自定地址：" stringByAppendingString: [DDDataHandler sharedData].customAddress];
                [self updateTitleOfButton:self.addressButton withString:newStr];
            } else {
                [self performSegueWithIdentifier:@"ChooseCustomAddress" sender:self];
            }
			break;
		}
		case 2:
		{
            NSLog(@"case2");
            if ([DDDataHandler sharedData].currentAddress) {
                NSString *newStr = [@"当前地址：" stringByAppendingString: [DDDataHandler sharedData].currentAddress];
                [self updateTitleOfButton:self.addressButton withString:newStr];
            } else {
                [self performSegueWithIdentifier:@"ChooseCustomAddress" sender:self];
            }
		}
	}
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        self.orderButton.enabled = NO;
    }
}

#pragma mark - PopTipView

- (IBAction)togglePopTipView:(id)sender {
    // Toggle popTipView when a standard UIButton is pressed
    if (nil == self.roundRectButtonPopTipView) {
        CMPopTipView *pop = [[CMPopTipView alloc] initWithMessage:@"如多人需要代驾，则选择多个司机"] ;
        pop.delegate = self;
        pop.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        pop.textColor = [UIColor darkGrayColor];
        pop.textFont = [UIFont systemFontOfSize:12];
        pop.borderColor = [UIColor clearColor];
        pop.borderWidth = 1.0;
        pop.has3DStyle = NO;
        pop.hasShadow = NO;
        pop.hasGradientBackground = NO;
        
        self.roundRectButtonPopTipView = pop;
        UIButton *button = (UIButton *)sender;
        [self.roundRectButtonPopTipView presentPointingAtView:button inView:self.view animated:YES];
    }
    else {
        // Dismiss
        [self.roundRectButtonPopTipView dismissAnimated:YES];
        self.roundRectButtonPopTipView = nil;
    }
}

- (IBAction)dismissPopTipView:(UIControl *)sender
{
    if (self.roundRectButtonPopTipView) {
        [self.roundRectButtonPopTipView dismissAnimated:YES];
        self.roundRectButtonPopTipView = nil;
    }
}


#pragma mark CMPopTipViewDelegate methods
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    // User can tap CMPopTipView to dismiss it
    self.roundRectButtonPopTipView = nil;
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
