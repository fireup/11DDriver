//
//  DDPinAnnotation_DefaultLoc.m
//  DDriver11
//
//  Created by ZBN on 14-7-30.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDPinAnnotation_DefaultLoc.h"

@implementation DDPinAnnotation_DefaultLoc

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        _coordinate = coord;
    }
    return self;
}


@end
