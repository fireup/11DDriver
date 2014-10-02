//
//  DDAFManager.m
//  DDriver
//
//  Created by ZBN on 14-8-17.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDAFManager.h"

@interface DDAFManager() {
    AFHTTPRequestOperationManager *_manager;
}

@end

@implementation DDAFManager

- (instancetype)initWithURL:(NSString *)URL parameters:(NSDictionary *)para delegate:(id<DDAFManagerDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.responseSerializer.acceptableContentTypes = [_manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        self.delegate = delegate;
        [_manager POST:URL parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([responseObject[@"result"] isEqualToString:@"pass"] ) {
                [self.delegate AFManagerDidFinishDownload:responseObject forURL:URL];
                
            } else if ([responseObject[@"result"] isEqualToString:@"error"]) {
                [self.delegate AFManagerDidFailedDownloadForURL:URL error:responseObject[@"message"]];
                
            } else {
                [self.delegate AFManagerDidGetResultErrorForURL:URL error:responseObject[@"message"]];
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self.delegate AFManagerDidFailedDownloadForURL:URL error:@"网络不通，请稍后再试"];
        }];
    }
    
    return self;
    
}

@end
