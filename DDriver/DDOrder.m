//
//  DDOrder.m
//  DDriver11
//
//  Created by ZBN on 14-7-14.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDOrder.h"

@implementation DDOrder

@synthesize rateStar = _rateStar;

- (DDDriver *)driver
{
    if (!_driver) {
        _driver = [[DDDriver alloc] init];
    }
    return _driver;
}

- (void)setRateStar:(NSString *)rateStar
{
    NSMutableString *rateInStar = [NSMutableString stringWithCapacity:0];
    int count = [rateStar intValue];
    if (count>5) {
        count = 5;
    }
    for (int i=0; i < count; i++) {
        [rateInStar appendString:@"⭐️"];
    }
    _rateStar = rateInStar;
}


@end
