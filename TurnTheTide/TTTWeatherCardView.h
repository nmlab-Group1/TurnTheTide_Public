//
//  TTTWeatherCardView.h
//  TTT_Classes
//
//  Created by Roger on 5/9/14.
//  Copyright (c) 2014 nmlab_Team1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTParameters.h"

@interface TTTWeatherCardView : UIView

- (BOOL)setWithRank:(int)rank;
- (void)becomeUpsideDown;
- (BOOL)becomeChosen;
- (BOOL)becomeUnchosen;
- (int)getRank;
- (double)getLife;
- (BOOL)isUsed;
- (BOOL)becomeUsedAndHidden;

@end
