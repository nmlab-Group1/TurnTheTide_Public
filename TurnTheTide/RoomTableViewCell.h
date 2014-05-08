//
//  RoomTableViewCell.h
//  TurnTheTide
//
//  Created by Jimmy Lee on 14/5/6.
//  Copyright (c) 2014年 nmlab_Team1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *playerCountImageView;
@property (weak, nonatomic) IBOutlet UIImageView *needCountImageView;
@property (weak, nonatomic) IBOutlet UILabel *ownerLabel;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;

@end
