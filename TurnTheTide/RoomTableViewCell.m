//
//  RoomTableViewCell.m
//  TurnTheTide
//
//  Created by Jimmy Lee on 14/5/6.
//  Copyright (c) 2014年 nmlab_Team1. All rights reserved.
//

#import "RoomTableViewCell.h"

@implementation RoomTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
