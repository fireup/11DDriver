//
//  DDLocHandler.h
//  DDriver11
//
//  Created by ZBN on 14-7-26.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AFNetworking/AFHTTPRequestOperationManager.h"
#import "BMapKit.h"

typedef enum locationType{
    CURRENTLOC,
    CUSTOMELOC
} locationType;

@protocol LocHandlerDelegate;

@interface DDLocHandler : NSObject

@property (weak, nonatomic) id <LocHandlerDelegate> delegate;
@property (nonatomic, getter=isActive) BOOL active;

+ (instancetype)sharedLocater;

- (void)updateCurrentLocationAndAddress;
- (void)convertAddressToLocation:(NSString *)address city:(NSString *)city;
//- (void)updateCurrentAddressWithLocation:(CLLocation *)location;
//- (void)updateAddressWithLocation:(CLLocation *)location withOption:(locationType)locType;
@end

@protocol LocHandlerDelegate <NSObject>

- (void)locHandlerDidFinishConvertAddress:(NSString *)address;
@optional
- (void)locHandlerDidFailConvertAddress:(NSString *)address;

@end
