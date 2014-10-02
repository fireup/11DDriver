//
//  DDPinAnnotation.m
//  DDriver11
//
//  Created by ZBN on 14-7-13.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDPinAnnotation.h"

@implementation DDPinAnnotation

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        _coordinate = coord;
    }
    return self;
}

- (NSString *)title
{
    return [DDDataHandler sharedData].customAddress ? [DDDataHandler sharedData].customAddress : nil;
}

@end
