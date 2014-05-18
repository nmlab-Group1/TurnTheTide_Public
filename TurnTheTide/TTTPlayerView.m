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

@property (strong, nonatomic) UIImageView * background;
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
    [self initBackground];
    
    [self initNameLabel];
    [self initTideImageView];
    [self initLifeImageViews];
}

- (void)initWeatherCard
{
    _weatherCardBack = [[UIImageView alloc] initWithFrame:CGRectMake(4, -80, 192, 288)];
    _weatherCardBack.contentMode = UIViewContentModeScaleToFill;
    _weatherCardBack.image = [UIImage imageNamed:@"WeatherCardBack"];
    _weatherCardBack.alpha = 0.0;
    [self addSubview:_weatherCardBack];
    
    _weatherCardFront = [[TTTWeatherCardView alloc] initWithFrame:CGRectMake(4, -80, 192, 288)];
    _weatherCardFront.contentMode = UIViewContentModeScaleToFill;
    _weatherCardFront.alpha = 0.0;
    [self addSubview:_weatherCardFront];
}

- (void)initBackground
{
    _background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, PLAYER_VIEW_WIDTH, PLAYER_VIEW_HEIGHT)];
    _background.backgroundColor = [UIColor whiteColor];
    _background.alpha = 0.5;
    [self addSubview:_background];
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
    if(_currentLife <= 0)
        return NO;
    --_currentLife;
    
    //animation
//    _background.backgroundColor = [UIColor redColor];
    TTTPlayerView *temp = [_lifeImageViews objectAtIndex:_currentLife];
    [UIView animateWithDuration:0.25
        delay:0.0
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
            [temp setFrame:CGRectMake(temp.frame.origin.x - 32, temp.frame.origin.y - 32, 96, 96)];
        }
        completion:^(BOOL finished){

            [UIView animateWithDuration:0.25
                delay:0.0
                options:UIViewAnimationOptionCurveEaseIn
                animations:^{
                    [temp setFrame:CGRectMake(temp.frame.origin.x + 32, temp.frame.origin.y + 32, 32, 32)];
                    [temp setAlpha:0.25];
                }
                completion:nil
            ];

        }
    ];
/*
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0*NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _background.backgroundColor = [UIColor whiteColor];
    });
*/    return YES;
}

- (void)setTide:(int)newTide
{
    if (newTide >= 0 && newTide <= TIDE_MAX)
    {
        //animation
        [self tideAnimation:_tide targetTide:newTide];
        _tide = newTide;
    }
}

- (void)setTideWithOrder:(int)newTide order:(int)order
{
    if (newTide >= 0 && newTide <= TIDE_MAX)
    {
        //animation
        [self tideAnimation:_tide targetTide:newTide];
        _tide = newTide;
    }
}

- (void)setTideWithNSN:(NSNumber *)newTideNSN
{
    int newTide = [newTideNSN integerValue];
    if (newTide >= 0 && newTide <= TIDE_MAX)
    {
        //animation
        [self tideAnimation:_tide targetTide:newTide];
        _tide = newTide;
    }
}

- (void)tideAnimation: (int)currentTide targetTide:(int)targetTide
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.125*NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _tideImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"TideCard_%d", currentTide]];
        if (currentTide < targetTide) {
            [self tideAnimation:(currentTide+1) targetTide:targetTide];
        }
        else if (currentTide > targetTide) {
            [self tideAnimation:(currentTide-1) targetTide:targetTide];
        }
    });
/*
    _tideImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"TideCard_%d", currentTide]];
    [NSThread sleepForTimeInterval:1];
    if (currentTide < targetTide) {
        [self tideAnimation:(currentTide+1) targetTide:targetTide];
    }
    else if (currentTide > targetTide) {
        [self tideAnimation:(currentTide-1) targetTide:targetTide];
    }
 */
/*
    [UIView animateWithDuration:10
        delay:10
        options:UIViewAnimationOptionCurveLinear
        animations:^{
            _tideImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"TideCard_%d", currentTide]];
        }
        completion:^(BOOL finished){
            if (currentTide < targetTide) {
                [self tideAnimation:(currentTide+1) targetTide:targetTide];
            }
            else if (currentTide > targetTide) {
                [self tideAnimation:(currentTide-1) targetTide:targetTide];
            }
        }
    ];
*/
}

- (void)setHasPlayed:(BOOL)hasPlayed
{
    _hasPlayed = hasPlayed;
    if (_hasPlayed == YES) {
        [UIView animateWithDuration:0.25 animations:^{
            [_weatherCardBack setAlpha:1.0];
            [_weatherCardFront setAlpha:0.0];
        }];
    }
    else {
        [UIView animateWithDuration:0.25 animations:^{
            [_weatherCardBack setAlpha:0.0];
            [_weatherCardFront setAlpha:0.0];
        }];
    }
}

- (void)setCardRankAndShow:(int)cardRank upsideDown:(BOOL)upsideDown
{
    [_weatherCardFront setWithRank:cardRank];
    if (upsideDown) {
        [_weatherCardFront becomeUpsideDown];
    }
    [UIView animateWithDuration:0.25 animations:^{
        [_weatherCardBack setAlpha:0.0];
        [_weatherCardFront setAlpha:1.0];
    }];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

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
/*
 [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
 [UIView setAnimationDuration:0.25];
 [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:temp cache:YES];
 [temp setAlpha:0.1];
 [UIView commitAnimations];
 */
/*
 [UIView beginAnimations:nil context:nil];
 [UIView setAnimationDuration:0.2];
 [temp setFrame:CGRectMake(temp.frame.origin.x + 16, temp.frame.origin.y + 16, 32, 32)];
 [UIView commitAnimations];
 */

@end
