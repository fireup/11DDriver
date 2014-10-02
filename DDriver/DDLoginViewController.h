//
//  DDLoginViewController.h
//  DDriver11
//
//  Created by ZBN on 14-7-1.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDLoginViewController : UIViewController 

@property (strong, nonatomic) void (^dismissBlock) (void);
@property (strong, nonatomic) void (^cancelBlock) (void);


@end
