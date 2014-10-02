//
//  DDDriverCell.h
//  DDriver
//
//  Created by Bonan Zhang on 5/09/2014.
//  Copyright (c) 2014 fireup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDDriverCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateStarLabel;

@end
