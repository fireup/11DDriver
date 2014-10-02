//
//  DDDriverInfo.h
//  DDriver11
//
//  Created by ZBN on 14-7-10.
//  Copyright (c) 2014年 fireup. All rights reserved.
//
//  To display driver detailed info.
//  Attach this view to driverdetailVC's main view, or orderdetailVC's main view.

#import <UIKit/UIKit.h>

@interface DDDriverInfoView : UIView

@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *rateStarLabel;
@property (strong, nonatomic) UILabel *jobCountsLabel;
@property (strong, nonatomic) UILabel *distanceLabel;


@end
