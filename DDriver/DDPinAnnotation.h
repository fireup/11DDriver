//
//  DDPinAnnotation.h
//  DDriver11
//
//  Created by ZBN on 14-7-13.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "BMapKit.h"

@interface DDPinAnnotation : NSObject <BMKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;

- (instancetype)initWithLocation:(CLLocationCoordinate2D)coord;

@end
