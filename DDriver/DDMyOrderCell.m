//
//  DDMyOrderCell.m
//  DDriver11
//
//  Created by ZBN on 14-7-13.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDMyOrderCell.h"

@implementation DDMyOrderCell



- (void)awakeFromNib
{
    // Initialization code
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [self addSubview:line];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
