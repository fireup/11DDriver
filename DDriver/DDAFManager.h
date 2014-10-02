//
//  DDAFManager.h
//  DDriver
//
//  Created by ZBN on 14-8-17.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DDAFManagerDelegate;

@interface DDAFManager : NSObject

@property (weak, nonatomic) id <DDAFManagerDelegate> delegate;

- (instancetype)initWithURL:(NSString *)URL parameters:(NSDictionary *)para delegate:(id <DDAFManagerDelegate>)delegate;
@end

@protocol DDAFManagerDelegate <NSObject>

- (void)AFManagerDidFinishDownload:(NSDictionary *)responseObj forURL:(NSString *)URL;

@optional
- (void)AFManagerDidFailedDownloadForURL:(NSString *)URL error:(NSString *)message;
- (void)AFManagerDidGetResultErrorForURL:(NSString *)URL error:(NSString *)message;

@end
