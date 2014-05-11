//
//  TTTWeatherCardView.m
//  TTT_Classes
//
//  Created by Roger on 5/9/14.
//  Copyright (c) 2014 nmlab_Team1. All rights reserved.
//

#import "TTTWeatherCardView.h"

@interface TTTWeatherCardView()

@property (nonatomic) int rank;
@property (nonatomic) double life;
@property (nonatomic) BOOL isChosen;
@property (nonatomic) BOOL isUsed;

@property (strong, nonatomic) UILabel * rankLabel;
@property (strong, nonatomic) UIImageView * lifeImageView;

@end

@implementation TTTWeatherCardView

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
    self.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"WeatherCard"]];
    _rank = 0;
    _life = 0;
    _isChosen = NO;
    _isUsed = NO;
    [self initRankLabel];
    [self initLifeImageView];
}

- (void)initRankLabel
{
    _rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 36, 36)];
    _rankLabel.text = @"0";
    _rankLabel.textColor = [UIColor whiteColor];
    _rankLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:32.0];
    _rankLabel.textAlignment = NSTextAlignmentCenter;
    _rankLabel.shadowColor = [UIColor blackColor];
    _rankLabel.shadowOffset = CGSizeMake(1, 1);
    [self addSubview:_rankLabel];
}

- (void)initLifeImageView
{
    _lifeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 48, 36, 36)];
    _lifeImageView.contentMode = UIViewContentModeTop;
    [self addSubview:_lifeImageView];
}

#pragma mark - Setting

- (BOOL)setWithRank:(int)rank
{
    _rank = rank;
    _life = [self countLife:rank];
    if (_life == -1) {
        return NO;
    }

    _rankLabel.text = [NSString stringWithFormat:@"%d", _rank];
    //[@(_rank) stringValue];
    [self updateLifeImageView];
    
    return YES;
}

- (void)updateLifeImageView
{
    if (_life == 0.5) {
        _lifeImageView.image = [UIImage imageNamed:@"Lifesaver_half"];
    }
    else if (_life == 1.0) {
        _lifeImageView.image = [UIImage imageNamed:@"Lifesaver"];
    }
}

- (double)countLife:(int)rank
{
    if (rank < WEATHER_MIN || rank > WEATHER_MAX) {
        return -1;
    }
    if (rank <= WEATHER_BOUNDARY_1 || rank > WEATHER_BOUNDARY_4) {
        return 0;
    }
    if (rank <= WEATHER_BOUNDARY_2 || rank > WEATHER_BOUNDARY_3) {
        return 0.5;
    }
    return 1;
}

#pragma mark - Activity

- (BOOL)becomeChosen
{
    if (_isChosen == NO) {
        _isChosen = YES;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [self setCenter:CGPointMake(self.center.x, self.center.y - 48)];
        [UIView commitAnimations];
        
        return YES;
    }
    return NO;
}

- (BOOL)becomeUnchosen
{
    if (_isChosen == YES) {
        _isChosen = NO;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [self setCenter:CGPointMake(self.center.x, self.center.y + 48)];
        [UIView commitAnimations];
        
        return YES;
    }
    return NO;
}

- (int)getRank
{
    return _rank;
}

- (BOOL)isUsed
{
    return _isUsed;
}

- (BOOL)becomeUsedAndHidden
{
    if (_isUsed) {
        return NO;
    }
    _isUsed = YES;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [self setAlpha:0.0];
    [UIView commitAnimations];

    [self setHidden:YES];
    return YES;
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
