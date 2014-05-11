//
//  TTTPlayerView.h
//  TTT_Classes
//
//  Created by Roger on 5/10/14.
//  Copyright (c) 2014 nmlab_Team1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTParameters.h"

@interface TTTPlayerView : UIView

- (BOOL)setNameAndLife:(NSString *)name life:(int)life;
- (void)setTide:(int)newTide;
- (BOOL)loseOneLife;


@end
