//
//  DDUserDetailViewController.m
//  DDriver11
//
//  Created by ZBN on 14-7-22.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDUserDetailViewController.h"
#import "AFNetworking/AFHTTPRequestOperationManager.h"
#import "DDSetDefaultLocViewController.h"

@interface DDUserDetailViewController () <UITextFieldDelegate, setDefaultLocDelegate, DDAFManagerDelegate> {
    DDAFManager *_manager;
    UIBarButtonItem *_tempItem;
}

@property (weak, nonatomic) IBOutlet UILabel *phoneNOLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *titleButtons;
@property (weak, nonatomic) IBOutlet UITextField *emergencyNOLabel;
@property (weak, nonatomic) IBOutlet UIButton *defaultAddressButton;

@property (strong, nonatomic) NSDictionary *defaultLoc;

@end

@implementation DDUserDetailViewController

- (IBAction)radioButtonTapped:(UIButton *)sender
{
    sender.selected = YES;
    for (UIButton *theOther in self.titleButtons) {
        if (theOther != sender) {
            theOther.selected = NO;
        }
    }
}

- (IBAction)logout:(UIButton *)sender
{
    NSDictionary *parameters = @{@"request": @"logout",
                                 @"session_id" : [DDDataHandler sharedData].sessionID,
                                 @"client" : [DDDataHandler sharedData].appPlatform,
                                 @"version" : [DDDataHandler sharedData].appVersion};
    //clear cookie
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie* cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    [DDDataHandler sharedData].login = NO;
    [DDDataHandler sharedData].phoneNO = @"";
    [DDDataHandler sharedData].sessionID = @"";
    [DDDataHandler sharedData].title = @"";
    [DDDataHandler sharedData].emergency = @"";
    [DDDataHandler sharedData].defaultLoc = @{};
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.phoneNOLabel.alpha = 0;
                     } completion:nil];
     
    [UIView animateWithDuration:0.3
                          delay:0.2
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                                    for (UIButton *button in self.titleButtons) {
                                    button.alpha = 0;
                                    }
                                }
                     completion:nil];
     
    [UIView animateWithDuration:0.3
                          delay:0.4
                        options:UIViewAnimationOptionAllowAnimatedContent
     
                     animations:^{
                         self.emergencyNOLabel.alpha = 0;
                     }
                     completion:nil];
    
    [UIView animateWithDuration:0.3
                          delay:0.6
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                                                      self.defaultAddressButton.titleLabel.alpha = 0;
                     } completion:^(BOOL finished){
                         [self.navigationController popViewControllerAnimated:YES];
                     }];
    
    _manager = [[DDAFManager alloc] initWithURL:LOGOUTURL parameters:parameters delegate:self];
}
 
- (IBAction)saveButtonTapped:(UIBarButtonItem *)sender
{
    _tempItem = self.navigationItem.rightBarButtonItem;
    UIActivityIndicatorView *aView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem.customView = aView;
    [aView startAnimating];
    
    NSString *title = [(UIButton *)self.titleButtons[0] isSelected] ? @"sir" : @"madam";
    NSString *emergency = self.emergencyNOLabel.text;
    NSString *defaultAddr = self.defaultAddressButton.titleLabel.text;
    
    if (![title isEqualToString:[DDDataHandler sharedData].title] || ![emergency isEqualToString:[DDDataHandler sharedData].emergency] || ![defaultAddr isEqualToString:[DDDataHandler sharedData].defaultLoc[@"address"]]) {

        NSDictionary *para = @{@"request": @"saveuserinfo",
                               @"session_id": [DDDataHandler sharedData].sessionID,
                               @"title": title,
                               @"emergency": emergency,
                               @"defaultloc": self.defaultLoc,
                               @"client": [DDDataHandler sharedData].appPlatform,
                               @"version": [DDDataHandler sharedData].appVersion};
        _manager = [[DDAFManager alloc] initWithURL:ACCOUNTSAVEURL parameters:para delegate:self];
     
    } else {
        self.navigationItem.rightBarButtonItem.customView = nil;
        self.navigationItem.rightBarButtonItem = _tempItem;
    }
}

- (void)AFManagerDidFinishDownload:(NSDictionary *)responseObj forURL:(NSString *)URL
{
    _manager = nil;
    if ([URL isEqualToString:LOGOUTURL]) {
        
    } else if ([URL isEqualToString:ACCOUNTSAVEURL]) {
        
        self.navigationItem.rightBarButtonItem.customView = nil;
        self.navigationItem.rightBarButtonItem = _tempItem;
        
        [DDDataHandler sharedData].title = [(UIButton *)self.titleButtons[0] isSelected] ? @"sir" : @"madam";
        [DDDataHandler sharedData].emergency = self.emergencyNOLabel.text;
        [DDDataHandler sharedData].defaultLoc = self.defaultLoc;
    }
}

- (void)AFManagerDidGetResultErrorForURL:(NSString *)URL error:(NSString *)message
{
    _manager = nil;
    [DDDataHandler blankTitleAlert:message];
    if ([URL isEqualToString:LOGOUTURL]) {
        
    } else if ([URL isEqualToString:ACCOUNTSAVEURL]) {
        self.navigationItem.rightBarButtonItem.customView = nil;
        self.navigationItem.rightBarButtonItem = _tempItem;
    }
}

- (void)AFManagerDidFailedDownloadForURL:(NSString *)URL error:(NSString *)message
{
    _manager = nil;
    [DDDataHandler blankTitleAlert:message];
    if ([URL isEqualToString:LOGOUTURL]) {
        
    } else if ([URL isEqualToString:ACCOUNTSAVEURL]) {
        self.navigationItem.rightBarButtonItem.customView = nil;
        self.navigationItem.rightBarButtonItem = _tempItem;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.phoneNOLabel.text = [DDDataHandler sharedData].phoneNO ? [DDDataHandler sharedData].phoneNO : @"";
    
    if ([DDDataHandler sharedData].title) {
        if ([[DDDataHandler sharedData].title isEqualToString:@"sir"]) {
            [(UIButton *)self.titleButtons[0] setSelected:YES];
        } else if ([[DDDataHandler sharedData].title isEqualToString:@"madam"]) {
            [(UIButton *)self.titleButtons[1] setSelected:YES];
        }
    } else {
        [(UIButton *)self.titleButtons[0] setSelected:YES];
    }
    if ([DDDataHandler sharedData].emergency) {
        self.emergencyNOLabel.text = [DDDataHandler sharedData].emergency;
    }
    if ([DDDataHandler sharedData].defaultLoc[@"address"]) {
        self.defaultAddressButton.titleLabel.text = [DDDataHandler sharedData].defaultLoc[@"address"];
    }
    
    UIImageView *disView = [[UIImageView alloc] initWithFrame:CGRectMake(self.defaultAddressButton.bounds.size.width-12, 12, 12, 12)];
    disView.image = [UIImage imageNamed:@"disclosure"];
    [self.defaultAddressButton addSubview:disView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), [DDDataHandler sharedData].defaultLoc[@"address"]);

    if (self.defaultLoc[@"address"]) {
        [self.defaultAddressButton setTitle:self.defaultLoc[@"address"] forState:UIControlStateNormal];
        
    } else if ([DDDataHandler sharedData].defaultLoc[@"address"]) {
        [self.defaultAddressButton setTitle:[DDDataHandler sharedData].defaultLoc[@"address"] forState:UIControlStateNormal];
    } else {
        self.defaultAddressButton.titleLabel.text = @"未设定";
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    self.navigationController.navigationBar.hidden = YES;
}

- (NSDictionary *)defaultLoc
{
    if (!_defaultLoc) {
        _defaultLoc = [[NSDictionary alloc] init];
    }
    return _defaultLoc;
}

#pragma mark - setDefaultLoc delegate

- (void)didSetDefaultLoc:(NSDictionary *)defaultLoc
{
    self.defaultLoc = defaultLoc;
}

#pragma mark - textfield delegate

//- (void)textViewDidEndEditing:(UITextView *)textView
//{
//    [textView resignFirstResponder];
//}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SetDefaultLoc"] && [segue.destinationViewController isKindOfClass:[DDSetDefaultLocViewController class]]) {
        DDSetDefaultLocViewController *sdvc = segue.destinationViewController;
        sdvc.delegate = self;

        if (self.defaultLoc[@"address"]) {
            sdvc.defaultLoc = [self.defaultLoc mutableCopy];
            
        } else if ([DDDataHandler sharedData].defaultLoc[@"address"]) {
            sdvc.defaultLoc = [[DDDataHandler sharedData].defaultLoc mutableCopy];
        }
    }
}


@end
