//
//  TTTPlayerView.h
//  TTT_Classes
//
//  Created by Roger on 5/10/14.
//  Copyright (c) 2014 nmlab_Team1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTParameters.h"
#import "TTTWeatherCardView.h"

@interface TTTPlayerView : UIView

- (BOOL)setNameAndLife:(NSString *)name life:(int)life;
- (void)setTide:(int)newTide;
- (void)setTideWithNSN:(NSNumber *)newTideNSN;
//- (void)setPlayed;
- (int)getTide;
- (BOOL)loseOneLife;
- (NSString*)getName;
- (int)getCurrentLifeNum;
- (void)setHasPlayed:(BOOL)hasPlayed;
- (void)setCardRankAndShow:(int)cardRank upsideDown:(BOOL)upsideDown;

@end
