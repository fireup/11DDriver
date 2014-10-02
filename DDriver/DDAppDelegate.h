//
//  DDAppDelegate.h
//  DDriver
//
//  Created by ZBN on 14-7-31.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DDLocHandler.h"
#import "WXApi.h"

@interface DDAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

