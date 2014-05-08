//
//  GlobalData.m
//  TTT_Classes
//
//  Created by Roger on 5/8/14.
//  Copyright (c) 2014 nmlab_Team1. All rights reserved.
//

#import "GlobalData.h"

static GlobalData *instance = nil;

@implementation GlobalData

+(GlobalData *)getInstance
{
    @synchronized(self)
    {
        if (instance == nil)
        {
            instance = [GlobalData new];
        }
    }
    return instance;
}

-(void)initAllMusic
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"BGM_Main_DaysAreLong" ofType:@"mp3"];
    _BGM_Main = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
    _BGM_Main.numberOfLoops = -1;
    
    path = [[NSBundle mainBundle] pathForResource:@"BGM_Game_MorningWalk" ofType:@"mp3"];
    _BGM_Game = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
    _BGM_Game.numberOfLoops = -1;
}
/*
-(void)playBGMMain
{
    [_BGM_Main play];
}

-(void)stopBGMMain
{
    [_BGM_Main stop];
}

-(void)playBGMGame
{
    [_BGM_Game play];
}

-(void)stopBGMGame
{
    [_BGM_Game stop];
}
*/


@end
