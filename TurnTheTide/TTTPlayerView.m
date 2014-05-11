//
//  TTTPlayerView.m
//  TTT_Classes
//
//  Created by Roger on 5/10/14.
//  Copyright (c) 2014 nmlab_Team1. All rights reserved.
//

#import "TTTPlayerView.h"

@interface TTTPlayerView()

@property (nonatomic) int tide;
@property (nonatomic) int totalLife;
@property (nonatomic) int currentLife;
@property (nonatomic) int playedWeatherCard;
@property (strong, nonatomic) NSString * name;
@property (nonatomic) BOOL hasPlayed;
@property (nonatomic) BOOL isDead;

@property (strong, nonatomic) UILabel * nameLabel;
@property (strong, nonatomic) UIImageView * tideImageView;
@property (strong, nonatomic) NSMutableArray * lifeImageViews;
//@property (strong, nonatomic) UIImageView * lifeImageView;

@end



@implementation TTTPlayerView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
    _tide = 0;
    _totalLife = 0;
    _currentLife = 0;
    _playedWeatherCard = 0;
    _name = @"";
    _hasPlayed = NO;
    _isDead = NO;
    [self setBackgroundColor:[UIColor clearColor]];
    [self initNameLabel];
    [self initTideImageView];
    [self initLifeImageViews];
}

- (void)initNameLabel
{
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 0, 200, 28)];
    _nameLabel.text = _name;
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:24.0];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    //_nameLabel.shadowColor = [UIColor blackColor];
    //_nameLabel.shadowOffset = CGSizeMake(1, 1);
    [self addSubview:_nameLabel];
}

- (void)initTideImageView
{
    _tideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(128, 32, 72, 96)];
    _tideImageView.contentMode = UIViewContentModeScaleToFill;
    _tideImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"TideCard_%d", _tide]];
    [self addSubview:_tideImageView];
}

- (void)initLifeImageViews
{
    _lifeImageViews = [[NSMutableArray alloc] init];
}

#pragma mark - Setting

- (BOOL) setNameAndLife:(NSString *)name life:(int)life
{
    if (name.length == 0) {
        return NO;
    }
    if (life < 0 || life > HAND_COUNT) {
        return NO;
    }
    
    _name = name;
    _totalLife = life;
    _currentLife = life;
    
    _nameLabel.text = _name;
    [self setLifeImages];
    
    return YES;
}

- (void)setLifeImages
{
    //total height: 96, width: 152
    //one image: 24*24
    //x align: 4, 24*6, 4
/*    if (_totalLife <= 6) {
        //y: 32 + [36, "24", 36]
        for (int i = 0; i < _totalLife; ++i) {
            [self setOneLifeImage:CGRectMake(4+24*i, 68, 24, 24)];
        }
    }
    else if (_totalLife <= 12){
        //y: 32 + [24, 24*2, 24]
        for (int i = 0; i < 6; ++i) {
            [self setOneLifeImage:CGRectMake(4+24*i, 56, 24, 24)];
        }
        for (int i = 0; i < _totalLife-6; ++i) {
            [self setOneLifeImage:CGRectMake(4+24*i, 80, 24, 24)];
        }
    }
*/
    
    //oneimage: 32*32
    int offsetY = 32 + 32 - 16*(_totalLife/4);
    for (int i = 0; i < _totalLife; ++i) {
        [self setOneLifeImage:CGRectMake(32*(i%4), offsetY+32*(i/4), 32, 32)];
    }
/*
    if (_totalLife <= 4) {
        //y: 32 + [32, "32", 32]
        for (int i = 0; i < _totalLife; ++i) {
            [self setOneLifeImage:CGRectMake(12+32*i, 64, 32, 32)];
        }
    }
    else if (_totalLife <= 8){
        //y: 32 + [16, 32*2, 16]
        for (int i = 0; i < _totalLife; ++i) {
            [self setOneLifeImage:CGRectMake(12+32*(i%4), 48+32*(i/4), 32, 32)];
        }
    }
    else if (_totalLife <= 12) {
        for (int i = 0; i < _totalLife; ++i) {
            [self setOneLifeImage:CGRectMake(12+32*(i%4), 32+32*(i/4), 32, 32)];
        }
    }
*/
}

- (void)setOneLifeImage:(CGRect)frame
{
    UIImageView *temp = [[UIImageView alloc] initWithFrame:frame];
    temp.contentMode = UIViewContentModeScaleToFill;
    temp.image = [UIImage imageNamed:@"Lifesaver_256"];
    [self addSubview:temp];
    [_lifeImageViews addObject:temp];
}

#pragma mark - Event

- (void)hasPlayed:(int)playedWeatherCardNum
{
    _playedWeatherCard = playedWeatherCardNum;
    //todo: change background
}

- (BOOL)loseOneLife     //check if die
{
    //animation
    
    
    --_currentLife;
    return YES;
}

- (void)setTide:(int)newTide
{
    if (newTide >= 0 && newTide <= TIDE_MAX)
    {
    //animation
    if (newTide > _tide)
    {
/*        for (int i = _tide + 1; i < newTide; ++i) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:10];
            _tideImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"TideCard_%d", i]];
            [UIView commitAnimations];
            
        }
*/        _tideImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"TideCard_%d", newTide]];
    }
    
    if (newTide < _tide)
    {
/*        for (int i = _tide - 1; i > newTide; --i) {
            _tideImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"TideCard_%d", i]];
            //sleep(2);
            //[NSThread sleepForTimeInterval:0.1f];
        }
*/        _tideImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"TideCard_%d", newTide]];
    }
    
    _tide = newTide;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
