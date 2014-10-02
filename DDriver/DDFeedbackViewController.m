//
//  DDFeedbackViewController.m
//  DDriver11
//
//  Created by ZBN on 14-7-1.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDFeedbackViewController.h"
#import "DDAFManager.h"

@interface DDFeedbackViewController () <UITextViewDelegate, DDAFManagerDelegate> {
    DDAFManager *_manager;
}

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation DDFeedbackViewController

- (IBAction)sendFeedback:(UIButton *)sender
{
    if ([self.textView.text length] == 0) {
        return;
    }
    NSDictionary *para = @{@"session_id": [DDDataHandler sharedData].sessionID,
                           @"content": self.textView.text,
                           @"client" : [DDDataHandler sharedData].appPlatform,
                           @"version" : [DDDataHandler sharedData].appVersion};
    _manager = [[DDAFManager alloc] initWithURL:FEEDBACKURL parameters:para delegate:self];
}

- (void)AFManagerDidFinishDownload:(NSDictionary *)responseObj forURL:(NSString *)URL
{
    [DDDataHandler blankTitleAlert:responseObj[@"message"]];
    _manager = nil;
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
    self.textView.layer.borderColor = [UIColor colorWithRed:(129/255.0) green:(157/255.0) blue:(202/255.0) alpha:1.0].CGColor;
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.cornerRadius = 10.0;
    self.textView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma  mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    if ([textView.text isEqualToString:@"欢迎提出宝贵意见"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"欢迎提出宝贵意见";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
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
