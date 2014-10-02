//
//  DDPinAnnotation_DefaultLoc.h
//  DDriver11
//
//  Created by ZBN on 14-7-30.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMapKit.h"

@interface DDPinAnnotation_DefaultLoc : NSObject <BMKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;

- (instancetype)initWithLocation:(CLLocationCoordinate2D)coord;


@end
