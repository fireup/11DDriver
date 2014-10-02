//
//  DDLoginViewController.m
//  DDriver11
//
//  Created by ZBN on 14-7-1.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDLoginViewController.h"
#import "AFNetworking/AFHTTPRequestOperationManager.h"
#import "DDDataHandler.h"

@interface DDLoginViewController () <DDAFManagerDelegate> {
    DDAFManager *_manager;
}

@property (weak, nonatomic) IBOutlet UITextField *phoneNoInput;
//@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIButton *getCodeButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIButton *submitCodeButton;
@property (strong, nonatomic) NSString *phoneNOSubmitted;

@end

@implementation DDLoginViewController

- (IBAction)getSMSCode:(UIButton *)sender
{
    self.getCodeButton.hidden = YES;
    [self.indicator startAnimating];
    self.phoneNOSubmitted = self.phoneNoInput.text;

    NSDictionary *parameters = @{@"request": @"requestsmscode",
                                 @"phoneno" : self.phoneNOSubmitted,
                                 @"client" : [DDDataHandler sharedData].appPlatform,
                                 @"version" : [DDDataHandler sharedData].appVersion};
    
    _manager = [[DDAFManager alloc] initWithURL:LOGINURL parameters:parameters delegate:self];
}

- (IBAction)verifySMSCode:(UIButton *)sender
{
    self.submitCodeButton.hidden = YES;
    self.getCodeButton.hidden = YES;
    [self.indicator startAnimating];
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSDictionary *parameters = @{@"request": @"verifysmscode",
                                 @"smscode" : self.phoneNoInput.text,
                                 @"phoneno" : self.phoneNOSubmitted,
                                 @"client" : [DDDataHandler sharedData].appPlatform,
                                 @"version" : [DDDataHandler sharedData].appVersion};
    _manager = [[DDAFManager alloc] initWithURL:VERIFYURL parameters:parameters delegate:self];


}

- (void)AFManagerDidFinishDownload:(NSDictionary *)responseObj forURL:(NSString *)URL
{
    [self.indicator stopAnimating];
    _manager = nil;
    
    if ([URL isEqualToString:LOGINURL]) {
        self.submitCodeButton.hidden = NO;
        self.phoneNoInput.text = @"";
        self.phoneNoInput.placeholder = @"请输入验证码";
        
    } else if ([URL isEqualToString:VERIFYURL]) {
        self.submitCodeButton.hidden = YES;
        self.phoneNoInput.text = @"";
        self.phoneNoInput.placeholder = @"";
        
        [DDDataHandler sharedData].login = YES;
        [DDDataHandler sharedData].phoneNO = self.phoneNOSubmitted;
        [DDDataHandler sharedData].sessionID = responseObj[@"customer_id"];
        [DDDataHandler sharedData].title = [responseObj[@"title"] isKindOfClass:[NSNull class]] ? @"" : responseObj[@"title"];
        [DDDataHandler sharedData].emergency = [responseObj[@"emergency"] isKindOfClass:[NSNull class]] ? @"" : responseObj[@"emergency"];
        if (![responseObj[@"default_address"] isKindOfClass:[NSNull class]] && ![responseObj[@"default_lat"] isKindOfClass:[NSNull class]] && ![responseObj[@"default_lng"] isKindOfClass:[NSNull class]]) {
            
            [DDDataHandler sharedData].defaultLoc = @{@"address": responseObj[@"default_address"],
                                                      @"latitude": responseObj[@"default_lat"],
                                                      @"longitude": responseObj[@"default_lng"]};
        }
        [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
    }
}

- (void)AFManagerDidFailedDownloadForURL:(NSString *)URL error:(NSString *)message
{
    [self.indicator stopAnimating];
    [DDDataHandler blankTitleAlert:message];
    if ([URL isEqualToString:LOGINURL]) {
        self.getCodeButton.hidden = NO;
        self.submitCodeButton.hidden = YES;
    
    } else if ([URL isEqualToString:VERIFYURL]) {
        self.phoneNoInput.text = @"";
        self.phoneNoInput.placeholder = @"请输入验证码";
        self.submitCodeButton.hidden = NO;
        self.getCodeButton.hidden = YES;
    }
    _manager = nil;
}

- (void)AFManagerDidGetResultErrorForURL:(NSString *)URL error:(NSString *)message
{
    [self.indicator stopAnimating];
    [DDDataHandler blankTitleAlert:message];
    if ([URL isEqualToString:LOGINURL]) {
        self.getCodeButton.hidden = NO;
        self.submitCodeButton.hidden = YES;
        
    } else if ([URL isEqualToString:VERIFYURL]) {
        self.phoneNoInput.text = @"";
        self.phoneNoInput.placeholder = @"请输入验证码";
        self.getCodeButton.hidden = NO;
        self.submitCodeButton.hidden = YES;
    }
    _manager = nil;
}


- (IBAction)cancel:(UIBarButtonItem *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.cancelBlock];
}

- (IBAction)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect frame = self.phoneNoInput.frame;
    frame.size.height = 40;
    self.phoneNoInput.frame = frame;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}



#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}
*/


@end
