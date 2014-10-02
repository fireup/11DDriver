//
//  DDDriver.h
//  DDriver11
//
//  Created by ZBN on 14-7-7.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "BMapKit.h"


@protocol DriverDelegate;

@interface DDDriver : NSObject <BMKAnnotation>

@property (copy, nonatomic) NSString *driverID;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *jobCount;
@property (copy, nonatomic) NSString *rateStar;
@property (copy, nonatomic) NSString *rateTitle;
@property (copy, nonatomic) NSString *phoneNO;
@property (copy, nonatomic) NSString *comment;
@property (nonatomic) BOOL isBusy;
@property (nonatomic) CLLocationDistance distanceInKM;

@property (copy, nonatomic) NSString *avatarURL;
//暂存头像url, 以备某些view先载入内容后载入图像使用.
@property (copy, nonatomic) NSString *avatarURLTemp;
@property (strong, nonatomic) UIImage *avatar;


@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (instancetype)initWithLocation:(CLLocationCoordinate2D)coord;
- (NSString *)title;
- (NSString *)subtitle;

@property (weak, nonatomic) id <DriverDelegate> delegate;

@end

@protocol DriverDelegate <NSObject>

- (void)didDownloadAvatarImageForDriver:(DDDriver *)driver;

@end

