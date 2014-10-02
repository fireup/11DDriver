//
//  DDDataHandler.h
//  DDriver
//
//  Created by ZBN on 14-7-31.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <BMapKit.h>
#import "DDLocHandler.h"

@interface DDDataHandler : NSObject

@property (nonatomic, getter = isLogin) BOOL login;
@property (nonatomic, strong) NSString *phoneNO;
@property (nonatomic, strong) NSString *sessionID;

@property (nonatomic, strong) BMKUserLocation *userLocation;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, copy) NSString *currentAddress;
@property (nonatomic, copy) NSString *city;

@property (nonatomic, strong) CLLocation *customLocation;
@property (nonatomic, copy) NSString *customAddress;

@property (nonatomic, strong) NSDictionary *defaultLoc;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *emergency;

@property (nonatomic, copy, readonly) NSString *appVersion;
@property (nonatomic, copy, readonly) NSString *appPlatform;

@property (nonatomic, strong) DDLocHandler *locHandler;

+ (NSDictionary *)convertItemToString:(NSDictionary *)dict;
+ (instancetype)sharedData;
+ (void)networkAlert;
+ (void)resultErrorAlert:(NSString *)errorMessage;
+ (void)blankTitleAlert:(NSString *)message;

@end
