//
//  GameViewController.h
//  TurnTheTide
//
//  Created by Jimmy Lee on 14/5/7.
//  Copyright (c) 2014年 nmlab_Team1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import "GlobalData.h"

@interface GameViewController : UIViewController

@property (strong, nonatomic) NSString* roomID;
@property (strong, nonatomic) NSString* name;

@end
