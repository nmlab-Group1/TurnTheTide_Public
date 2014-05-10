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
@property (nonatomic) int life;
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
    }
    return self;
}

- (void)awakeFromNib
{
    _tide = 0;
    _life = 0;
    _name = @"";
    _hasPlayed = NO;
    _isDead = NO;
    [self setBackgroundColor:[UIColor whiteColor]];
    [self initNameLabel];
    [self initTideImageView];
    [self initLifeImageViews];
}

- (void)initNameLabel
{
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 4, 224, 28)];
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
    _tideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(152, 32, 72, 96)];
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
    
    return YES;
}

#pragma mark - Setting

- (BOOL)loseOneLife     //check if die
{
    
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
