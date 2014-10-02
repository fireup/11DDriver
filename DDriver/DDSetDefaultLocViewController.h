//
//  DDSetDefaultLocViewController.h
//  DDriver11
//
//  Created by ZBN on 14-7-30.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

@protocol setDefaultLocDelegate;

#import <UIKit/UIKit.h>

@interface DDSetDefaultLocViewController : UIViewController

@property (nonatomic, strong) NSMutableDictionary *defaultLoc;

@property  (weak, nonatomic) id <setDefaultLocDelegate> delegate;

@end

@protocol setDefaultLocDelegate <NSObject>

- (void)didSetDefaultLoc:(NSDictionary *)defaultLoc;

@end
