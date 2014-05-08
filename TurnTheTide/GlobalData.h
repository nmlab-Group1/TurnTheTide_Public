//
//  GlobalData.h
//  TTT_Classes
//
//  Created by Roger on 5/8/14.
//  Copyright (c) 2014 nmlab_Team1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface GlobalData : NSObject

@property (strong, nonatomic)AVAudioPlayer * BGM_Main;
@property (strong, nonatomic)AVAudioPlayer * BGM_Game;

+(GlobalData *)getInstance;

-(void)initAllMusic;

/*
-(void)playBGMMain;
-(void)stopBGMMain;
-(void)playBGMGame;
-(void)stopBGMGame;
*/

@end
