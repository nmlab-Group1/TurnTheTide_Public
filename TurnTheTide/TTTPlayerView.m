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

@property (strong, nonatomic) UIImageView * weatherCardBack;
@property (strong, nonatomic) TTTWeatherCardView * weatherCardFront;
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
    [self initWeatherCard];
    
    [self initNameLabel];
    [self initTideImageView];
    [self initLifeImageViews];
}

- (void)initWeatherCard
{
    _weatherCardBack = [[UIImageView alloc] initWithFrame:CGRectMake(4, -60, 192, 288)];
    _weatherCardBack.contentMode = UIViewContentModeScaleToFill;
    _weatherCardBack.image = [UIImage imageNamed:@"WeatherCardBack"];
    _weatherCardBack.alpha = 0.5;
    _weatherCardBack.hidden = YES;
    [self addSubview:_weatherCardBack];
    
    _weatherCardFront = [[TTTWeatherCardView alloc] initWithFrame:CGRectMake(4, -60, 192, 288)];
    _weatherCardFront.contentMode = UIViewContentModeScaleToFill;
    _weatherCardFront.alpha = 0.5;
    _weatherCardFront.hidden = YES;
    [self addSubview:_weatherCardFront];
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

#pragma mark - Setter

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
    //total height: 96, width: 128
    //one image: 32*32
    //x align: 32*n
    //y align: 32+32 , 32+16, 32+0
    
    //one image: 32*32
    int offsetY = 32 + ( 32 - 16*( (_totalLife-1)/4 ) );
    for (int i = 0; i < _totalLife; ++i) {
        [self setOneLifeImage:CGRectMake(32*(i%4), offsetY+32*(i/4), 32, 32)];
    }
}

- (void)setOneLifeImage:(CGRect)frame
{
    UIImageView *temp = [[UIImageView alloc] initWithFrame:frame];
    temp.contentMode = UIViewContentModeScaleToFill;
    temp.image = [UIImage imageNamed:@"Lifesaver_256"];
    [self addSubview:temp];
    [_lifeImageViews addObject:temp];
}

- (NSString*)getName
{
    return _name;
}

- (int)getTide
{
    return _tide;
}

#pragma mark - getter

- (int)getCurrentLifeNum
{
    NSLog(@"%d", _currentLife);
    return _currentLife;
}

#pragma mark - Event
/*
- (void)hasPlayed:(int)playedWeatherCardNum
{
    _playedWeatherCard = playedWeatherCardNum;
    //todo: change background
}
*/
- (BOOL)loseOneLife     //check if die
{
    --_currentLife;
    if(_currentLife < 0)
        return NO;
    //animation
    TTTPlayerView *temp = [_lifeImageViews objectAtIndex:_currentLife];
/*
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
//    [temp setFrame:CGRectMake(temp.frame.origin.x - 16, temp.frame.origin.y - 16, 64, 64)];
    temp.Alpha = 0.1;
    [UIView commitAnimations];
*/
/*
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [temp setFrame:CGRectMake(temp.frame.origin.x - 16, temp.frame.origin.y - 16, 64, 64)];
    [UIView commitAnimations];
*/
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:temp cache:YES];
    [temp setAlpha:0.1];
    [UIView commitAnimations];
/*
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [temp setFrame:CGRectMake(temp.frame.origin.x + 16, temp.frame.origin.y + 16, 32, 32)];
    [UIView commitAnimations];
*/
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

- (void)setHasPlayed:(BOOL)hasPlayed
{
    _hasPlayed = hasPlayed;
    if (_hasPlayed == YES) {
        _weatherCardBack.hidden = NO;
        _weatherCardFront.hidden = YES;
    }
    else {
        _weatherCardBack.hidden = YES;
        _weatherCardFront.hidden = YES;
    }
}

- (void)setCardRankAndShow:(int)cardRank upsideDown:(BOOL)upsideDown
{
    [_weatherCardFront setWithRank:cardRank];
    if (upsideDown) {
        [_weatherCardFront becomeUpsideDown];
    }
    _weatherCardFront.alpha = 0.0;
    _weatherCardFront.hidden = NO;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    _weatherCardFront.alpha = 1.0;
    _weatherCardBack.alpha = 0.0;
    [UIView commitAnimations];

    _weatherCardBack.hidden = YES;
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
