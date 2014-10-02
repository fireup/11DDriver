//
//  DDMyAnnotationView.h
//  DDriver11
//
//  Created by ZBN on 14-7-8.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "BMapKit.h"

@protocol MyAnnotationViewDelegate;

@interface DDMyAnnotationView : BMKAnnotationView

@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *distanceLabel;
@property (strong, nonatomic) UILabel *rateLabel;
@property (strong, nonatomic) UILabel *rateStarLabel;
@property (strong, nonatomic) UIImageView *pinView;
@property (strong, nonatomic) UIView *bubbleView;
@property (weak, nonatomic) id <MyAnnotationViewDelegate> delegate;

@end

@protocol MyAnnotationViewDelegate <NSObject>

- (void)myAnnotationView:(DDMyAnnotationView *)aView bubbleViewTapped:(UIControl *)control;

@end
