//
//  DDPriceDetailViewController.m
//  DDriver
//
//  Created by ZBN on 14-8-16.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDPriceDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

#define AFURL GETPRICEURL

@interface DDPriceDetailViewController () <DDAFManagerDelegate> {
    DDAFManager *_manager;
}

@property (strong, nonatomic) NSArray *prices;

@end

@implementation DDPriceDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (![DDDataHandler sharedData].city) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"未知城市" message:@"请定位当前城市" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSDictionary *para = @{@"branch_name": [DDDataHandler sharedData].city};
    _manager = [[DDAFManager alloc] initWithURL:AFURL parameters:para delegate:self];
}


- (void)AFManagerDidFinishDownload:(NSDictionary *)responseObj forURL:(NSString *)URL
{
    if ([URL isEqualToString:AFURL]) {
        self.prices = responseObj[@"prices"];
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

- (void)setPrices:(NSArray *)prices
{
    _prices = prices;
    
    for (int i=0; i<prices.count; i++) {
        NSDictionary *price = prices[i];
        UIImageView *priceView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 50+40*i, self.view.bounds.size.width-40, 40)];
        [self.view addSubview:priceView];
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 120, 20)];
        timeLabel.text = price[@"period"];
        [priceView addSubview:timeLabel];
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 10, 120, 20)];
        priceLabel.text = price[@"price"];
        [priceView addSubview:priceLabel];
        
        UIGraphicsBeginImageContext(priceView.frame.size);   //开始画线
        [priceView.image drawInRect:CGRectMake(0, 0, priceView.frame.size.width, priceView.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);  //设置线条终点形状
        
        
        float lengths[] = {5,5};
        CGContextRef line = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(line, [UIColor lightGrayColor].CGColor);
        
        CGContextSetLineDash(line, 0, lengths, 1);  //画虚线
        CGContextMoveToPoint(line, 0.0, 40.0);    //开始画线
        CGContextAddLineToPoint(line, priceView.bounds.size.width, priceView.bounds.size.height);
        CGContextStrokePath(line);
        
        priceView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(40, 50+20+40*self.prices.count, self.view.bounds.size.width-80, 160)];
    textView.editable = NO;
    NSDictionary *price = self.prices[0];
    NSString *basicDistance = price[@"basic_distance"];
    NSString *waitPrice = price[@"unit_price_waiting"];
    NSString *extraPrice = price[@"unit_price_out_of_basic"];
    NSString *theText = [NSString stringWithFormat:@"注：\r1、不同时段的代驾起步费以实际出发时间为准。\r2、代驾距离超过%@公里后，每%@公里加收%@元，不足%@公里按%@公里计算。\r3、等候时间每满30分钟收费%@元，不满30分钟不收费。", basicDistance, basicDistance,extraPrice,basicDistance,basicDistance,waitPrice];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.headIndent = 15;
//    paragraphStyle.firstLineHeadIndent = 15;
    
    paragraphStyle.lineSpacing = 7;
    
    NSDictionary *attrsDictionary =@{NSParagraphStyleAttributeName: paragraphStyle};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:theText attributes:attrsDictionary];
    textView.attributedText = attrStr;
    
    [self.view addSubview:textView];

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
