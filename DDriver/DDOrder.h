//
//  DDOrder.h
//  DDriver11
//
//  Created by ZBN on 14-7-14.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDDriver.h"

@interface DDOrder : NSObject

@property (nonatomic) BOOL isCurrent;
@property (copy, nonatomic) NSString *orderID;
@property (nonatomic, copy) NSString *bookTime;
@property (nonatomic, copy) NSString *start;
@property (nonatomic, copy) NSString *destination;
@property (nonatomic, copy) NSString *fare;
@property (nonatomic, copy) NSString *otherInfo;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *rateStar;

@property (nonatomic, strong) DDDriver *driver;

@end
