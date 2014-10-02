//
//  DDDriverInfo.m
//  DDriver11
//
//  Created by ZBN on 14-7-10.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDDriverInfoView.h"

@implementation DDDriverInfoView

- (id)initWithFrame:(CGRect)frame
{
    if (frame.size.height < 140) {
        @throw [NSException exceptionWithName:@"init fail" reason:@"view height at least 140pt" userInfo:nil];
        return nil;
    }
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat height = self.bounds.size.height;
        CGFloat width = self.bounds.size.width;
        //上下灰线
        UILabel *upperLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0.5)];
        upperLine.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        UILabel *lowerLine = [[UILabel alloc] initWithFrame:CGRectMake(0, height, width, 0.5)];
        lowerLine.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        [self addSubview:upperLine];
        [self addSubview:lowerLine];
        
        self.avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(22, 12, 72, 72)];
        [self addSubview:self.avatarView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 25, 75, 25)];
        self.nameLabel.textColor = [UIColor colorWithRed:(42/255.0) green:(77/255.0) blue:(152/255.0) alpha:1.0];
        self.nameLabel.font = [UIFont systemFontOfSize:20];
        [self addSubview:self.nameLabel];
        
        self.rateStarLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 60, 85, 15)];
        self.rateStarLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.rateStarLabel];
        
        self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, 95, 63, 15)];
        self.distanceLabel.font = [UIFont systemFontOfSize:14];
        self.distanceLabel.textColor = [UIColor redColor];
        [self addSubview:self.distanceLabel];
        
        self.jobCountsLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 95, 90, 15)];
        self.jobCountsLabel.font = [UIFont systemFontOfSize:14];
        self.jobCountsLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:self.jobCountsLabel];

        
    }
    return self;
}




@end
