//
//  DDCustomAddressVC.m
//  DDriver
//
//  Created by Bonan Zhang on 4/09/2014.
//  Copyright (c) 2014 fireup. All rights reserved.
//

#import "DDCustomAddressVC.h"

@interface DDCustomAddressVC () <UITextFieldDelegate, LocHandlerDelegate> {
    DDLocHandler *_locHandler;
    UIActivityIndicatorView *_iView;
}

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UITextField *addressField;

@end

@implementation DDCustomAddressVC

- (IBAction)saveButtonTapped:(UIBarButtonItem *)sender
{
    if ([self.addressField.text length] > 0 && [self.cityLabel.text length] > 0) {
        _iView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.navigationItem.rightBarButtonItem.customView = _iView;
        [_iView startAnimating];
        _locHandler = [DDLocHandler sharedLocater];
        _locHandler.delegate = self;
        [_locHandler convertAddressToLocation:self.addressField.text city:self.cityLabel.text];
    }
}

- (IBAction)clearButtonTapped:(UIButton *)sender
{
    self.addressField.text = @"";
    [DDDataHandler sharedData].customLocation = nil;
    [DDDataHandler sharedData].customAddress = nil;
}

#pragma mark - locHandler delegate

- (void)locHandlerDidFinishConvertAddress:(NSString *)address
{
    _locHandler.delegate = nil;
    _locHandler = nil;
    [_iView removeFromSuperview];
    _iView = nil;
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)locHandlerDidFailConvertAddress:(NSString *)address
{
    _locHandler.delegate = nil;
    _locHandler = nil;
}



#pragma mark - lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.addressField.delegate = self;
    if (![DDDataHandler sharedData].city) {
        [DDDataHandler blankTitleAlert:@"请先定位当前城市"];
    } else {
        self.cityLabel.text = [DDDataHandler sharedData].city;
    }
    
    if ([DDDataHandler sharedData].customAddress) {
        self.addressField.text = [DDDataHandler sharedData].customAddress;
    }
}

#pragma mark - textField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.addressField resignFirstResponder];
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
