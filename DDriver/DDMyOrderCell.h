//
//  DDMyOrderCell.h
//  DDriver11
//
//  Created by ZBN on 14-7-13.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDMyOrderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateStarLabel;
@property (weak, nonatomic) IBOutlet UILabel *bookTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@end
