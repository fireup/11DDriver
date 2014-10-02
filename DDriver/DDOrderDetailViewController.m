//
//  DDOrderDetailViewController.m
//  DDriver11
//
//  Created by ZBN on 14-7-14.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DDOrderDetailViewController.h"
#import "DDDriverInfoView.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface DDOrderDetailViewController () <UITextViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, DDAFManagerDelegate> {
    DDAFManager *_manager;
    NSUInteger _rateStar;
}

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *destination;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;
@property (weak, nonatomic) IBOutlet UIView *start;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceOnLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *scoreView;
@property (weak, nonatomic) IBOutlet UIButton *reviewButton;

@property (weak, nonatomic) IBOutlet UITextView *writeTextView;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *myScore;

@end

@implementation DDOrderDetailViewController

- (IBAction)scoreStarTapped:(UIButton *)sender
{
    if ([self.order.rateStar length] > 0) {
        [DDDataHandler blankTitleAlert:@"您已评价过本订单"];
        return;
    }
    _rateStar = [self.myScore indexOfObject:sender];
    for (int i=0; i < [self.myScore count]; i++) {
        if (i <= _rateStar) {
            ((UIButton *)self.myScore[i]).selected = YES;
        } else {
            ((UIButton *)self.myScore[i]).selected = NO;
        }
    }
}

- (IBAction)comSubmitButtonTapped:(UIButton *)sender
{
    if (_rateStar > 0 || ![self.writeTextView.text isEqualToString:@"再说说你的感受"]) {
        NSDictionary *para = @{@"request": @"commentondriver",
                               @"session_id": [DDDataHandler sharedData].sessionID,
                               @"driver_id": self.order.driver.driverID,
                               @"order_id": self.order.orderID,
                               @"ratestar": [NSString stringWithFormat:@"%d", _rateStar],
                               @"comment": [self.writeTextView.text isEqualToString:@"再说说你的感受"] ? @"" : self.writeTextView.text,
                               @"client" : [DDDataHandler sharedData].appPlatform,
                               @"version" : [DDDataHandler sharedData].appVersion};
        _manager = [[DDAFManager alloc] initWithURL:COMMENTURL parameters:para delegate:self];
        self.reviewButton.enabled = NO;
    }
}

- (void)AFManagerDidFinishDownload:(NSDictionary *)responseObj forURL:(NSString *)URL
{
    _manager = nil;
    NSString *message = responseObj[@"message"] ? responseObj[@"message"] : @"感谢你的评价！";
    self.reviewButton.enabled = NO;
    [DDDataHandler blankTitleAlert:message];
}

- (void)AFManagerDidFailedDownloadForURL:(NSString *)URL error:(NSString *)message
{
    _manager = nil;
    self.reviewButton.enabled = YES;
    [DDDataHandler blankTitleAlert:message];
}

- (void)AFManagerDidGetResultErrorForURL:(NSString *)URL error:(NSString *)message
{
    _manager = nil;
    self.reviewButton.enabled = YES;
    [DDDataHandler blankTitleAlert:message];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.scrollView setContentSize:CGSizeMake(320, 619)];
    
    //页首时间label
    self.orderTimeLabel.text = [NSString stringWithFormat:@"预约时间：%@", self.order.bookTime];
    
    //页中部司机详情view
    DDDriverInfoView *dView = [[DDDriverInfoView alloc] initWithFrame:CGRectMake(0, 30, self.view.bounds.size.width, 140)];
    dView.nameLabel.text = self.order.driver.name;
    dView.avatarView.image = self.order.driver.avatar;
    dView.rateStarLabel.text = self.order.driver.rateStar;
    dView.jobCountsLabel.text = [NSString stringWithFormat:@"代驾 %@ 次", self.order.driver.jobCount];
    
    [self.scrollView addSubview:dView];
    
    //页中部起点、终点地址label，加边框。
    self.start.layer.borderColor = [UIColor colorWithRed:(42/255.0) green:(77/255.0) blue:(152/255.0) alpha:1.0].CGColor;
    self.start.layer.borderWidth = 0.5;
    self.start.layer.cornerRadius = 10.0;
    if (self.order.start) {
        self.startLabel.text = self.order.start;
    }

    self.destination.layer.borderColor = [UIColor colorWithRed:(42/255.0) green:(77/255.0) blue:(152/255.0) alpha:1.0].CGColor;
    self.destination.layer.borderWidth = 0.5;
    self.destination.layer.cornerRadius = 10.0;
    if (self.order.destination) {
        self.destinationLabel.text = self.order.destination;
    }
    
    UILabel *dLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 305, self.view.bounds.size.width, 0.5)];
    dLine.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [self.scrollView addSubview:dLine];
    
    //页中部“正在进行中”label
    if (self.order.isCurrent) {
        
    } else if (self.order.fare) {
        NSString *fareStr = [NSString stringWithFormat:@"消费金额：   %6@     元", self.order.fare];
        NSMutableAttributedString *newAttrStr = [[NSMutableAttributedString alloc] initWithString:fareStr];
        [newAttrStr addAttribute:NSForegroundColorAttributeName
                           value:[UIColor orangeColor]
                           range:NSMakeRange(8, 4)];
        self.serviceOnLabel.attributedText = newAttrStr;
    }
    
    //页中部 其他信息 label
    self.otherInfoLabel.text = self.order.otherInfo ? [NSString stringWithFormat:@"* %@", self.order.otherInfo] : @"";

    //设置评论部分背景
    self.scoreView.contentMode = UIViewContentModeScaleToFill;
    self.scoreView.image = [UIImage imageNamed:@"scorebg"];
    
    self.writeTextView.layer.borderColor = [UIColor colorWithRed:(129/255.0) green:(157/255.0) blue:(202/255.0) alpha:1.0].CGColor;
    self.writeTextView.layer.borderWidth = 0.5;
    self.writeTextView.layer.cornerRadius = 10.0;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textAreaTapped)];
    [self.writeTextView addGestureRecognizer:gesture];
    
    if ([self.order.comment length]>0 && [self.order.rateStar length]>0) {
        self.reviewButton.enabled = NO;
        
    } else {
        self.reviewButton.enabled = YES;
    }
}

- (void)textAreaTapped
{
    if ([self.order.comment length]>0) {
        [DDDataHandler blankTitleAlert:@"您已评价过本订单"];
        return;
    }
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"快速评论"
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"满意", @"非常满意", @"这个师傅服务不错，赞一个",nil];
    [action showInView:self.view];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < 3) {
        self.writeTextView.text = [actionSheet buttonTitleAtIndex:buttonIndex];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];


}


@end
