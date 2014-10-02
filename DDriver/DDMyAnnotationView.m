//
//  DDMyAnnotationView.m
//  DDriver11
//
//  Created by ZBN on 14-7-8.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDMyAnnotationView.h"

@implementation DDMyAnnotationView



- (instancetype)initWithAnnotation:(id <BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Set the frame size to the appropriate values.
        CGRect  myFrame = self.frame;
        myFrame.size.width = 158;
        myFrame.size.height = 130;
        self.frame = myFrame;
        
        //pin:26*26; bubble:158*80; ratetitle:158*24;
        self.pinView = [[UIImageView alloc] initWithFrame:CGRectMake(52, 104, 26, 26)];
        self.pinView.image = [UIImage imageNamed:@"aView_pin"];
        [self addSubview:self.pinView];
        
        UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        imageButton.frame = CGRectMake(0, 24, 158, 80);    
        [imageButton setImage:[UIImage imageNamed:@"aView_bubble"] forState:UIControlStateNormal];
        [imageButton addTarget:self action:@selector(bubbleViewTapped) forControlEvents:UIControlEventTouchUpInside];
        self.bubbleView = imageButton;
        [self addSubview:self.bubbleView];
        
        self.avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 45, 20)];
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(113, 10, 37, 15)];
        self.distanceLabel.textColor = [UIColor redColor];
        self.distanceLabel.adjustsFontSizeToFitWidth = YES;
        self.rateStarLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, 80, 20)];
        self.rateStarLabel.font =[UIFont systemFontOfSize:11.0];
        
        [self.bubbleView addSubview:self.avatarView];
        [self.bubbleView addSubview:self.nameLabel];
        [self.bubbleView addSubview:self.distanceLabel];
        [self.bubbleView addSubview:self.rateStarLabel];
        
        // The opaque property is YES by default. Setting it to
        // NO allows map content to show through any unrendered parts of your view.
        self.opaque = NO;

    }
    return self;
}

//set rateLabel.text的时候（相当于先getRateLabel），此时把rateLabel的背景图片加入。
- (UILabel *)rateLabel
{
    if (!_rateLabel) {
        _rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 156, 21)];
        _rateLabel.textAlignment = NSTextAlignmentCenter;
        _rateLabel.textColor = [UIColor whiteColor];
        UIImageView *rateLabelBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 3, 156, 21)];
        rateLabelBG.image = [UIImage imageNamed:@"aView_rateLabelBG"];
        [rateLabelBG addSubview:_rateLabel];
        UIImageView *crownView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aView_crown"]];
        
        [self addSubview:rateLabelBG];
        [self addSubview:crownView];
    };
    return _rateLabel;
}


- (void)bubbleViewTapped
{
    [self.delegate myAnnotationView:self bubbleViewTapped:(UIControl *)self.bubbleView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
