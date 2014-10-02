//
//  DDDriver.m
//  DDriver11
//
//  Created by ZBN on 14-7-7.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDDriver.h"
#import "AFNetworking/AFHTTPRequestOperation.h"

@interface DDDriver ()

@end

@implementation DDDriver

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        _coordinate = coord;
    }
    return self;
}

- (void)setAvatarURL:(NSString *)avatarURL
{
    _avatarURL = avatarURL;
    
    if (avatarURL) {
        
        NSURL *URL = [NSURL URLWithString:avatarURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFImageResponseSerializer serializer];
        
        //设置driver的avatar为下载到的图像，并通知delegate(DDNearMeVC)更新MyAnnotationView。
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            self.avatar = responseObject;
            [self.delegate didDownloadAvatarImageForDriver:self];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"The Error is: %@", error);
        }];
        
        [op start];
    }
}

- (void)setAvatar:(UIImage *)avatar
{
    CGSize origImageSize = avatar.size;
    //程序中最大的司机头像尺寸是72*72, 因此将头像设置为此尺寸.
    CGRect newRect = CGRectMake(0, 0, 72, 72);
    float ratio = MAX(newRect.size.width / origImageSize.width, newRect.size.height / origImageSize.height);
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:newRect];
    [path addClip];
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    [avatar drawInRect:projectRect];
    [[UIColor colorWithRed:(42/255.0) green:(77/255.0) blue:(152/255.0) alpha:1.0] setStroke];
    [path setLineWidth:3.0];
    [path stroke];
    
    _avatar = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}

- (void)setRateStar:(NSString *)rateStar
{
    NSMutableString *rateInStar = [NSMutableString stringWithCapacity:0];
    int count = [rateStar intValue];
    if (count>5) {
        count = 5;
    }
    for (int i=0; i < count; i++) {
        [rateInStar appendString:@"⭐️"];
    }
    _rateStar = rateInStar;
}

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    return self.rateStar;
}

@end
