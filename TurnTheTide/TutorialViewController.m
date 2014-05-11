//
//  TutorialViewController.m
//  TurnTheTide
//
//  Created by Roger on 4/27/14.
//  Copyright (c) 2014 nmlab_Team1. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()

@property (strong, nonatomic) NSMutableArray *weatherCards;
@property (weak, atomic) TTTWeatherCardView *chosenCard;
@property (strong, nonatomic) UISwipeGestureRecognizer * tempRecog;

@property (strong, nonatomic) TTTPlayerView *testPlayer;
@property (strong, nonatomic) NSMutableArray *playerViews;

@end

@implementation TutorialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    GlobalData * globalData = [GlobalData getInstance];
    [globalData.BGM_Main stop];
    [globalData.BGM_Game play];
    
    [self initWeatherCards];
    [self initGestureOfWeatherCards];
    
    [self initPlayerViews:3];
    NSLog(@"%d", [_playerViews count]);
}

- (void)initWeatherCards
{
    _weatherCards = [[NSMutableArray alloc] init];
    for (int i = 0; i < HAND_COUNT; ++i) {
        TTTWeatherCardView* tempCard = [[TTTWeatherCardView alloc] initWithFrame:CGRectMake(72+64*i, 672, 192, 288)];
        [self.view addSubview:tempCard];
        [_weatherCards addObject:tempCard];
    }
}

- (void)initGestureOfWeatherCards
{
    for (int i = 0; i < HAND_COUNT; ++i) {
        _tempRecog = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
        [_tempRecog setDirection:UISwipeGestureRecognizerDirectionUp];
        [[_weatherCards objectAtIndex:i] addGestureRecognizer:_tempRecog];
    }
    for (int i = 0; i < HAND_COUNT; ++i) {
        _tempRecog = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
        [_tempRecog setDirection:UISwipeGestureRecognizerDirectionDown];
        [[_weatherCards objectAtIndex:i] addGestureRecognizer:_tempRecog];
    }
}

- (void)initPlayerViews:(int)playerCount
{
    int intervalX = (1024 - playerCount * PLAYER_VIEW_WIDTH)/(playerCount+1);
    int offsetY = 16;
    
    _playerViews = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < playerCount; ++i) {
        TTTPlayerView *temp = [[TTTPlayerView alloc] initWithFrame:CGRectMake(intervalX*(i+1) + PLAYER_VIEW_WIDTH*i, offsetY, PLAYER_VIEW_WIDTH, PLAYER_VIEW_HEIGHT)];
        [temp setNameAndLife:@"test player" life:10];
NSLog(@"%d %d", -546, [temp getCurrentLifeNum]);
        [_playerViews addObject:temp];
        [self.view addSubview:temp];
    }
}

#pragma mark - terminate

- (void)viewDidDisappear:(BOOL)animated
{
    GlobalData * globalData = [GlobalData getInstance];
    [globalData.BGM_Game stop];
    [globalData.BGM_Main play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - navigation

- (IBAction)navigationBack:(UIButton *)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - methods

- (IBAction)testButton:(UIButton *)sender {
    [[_playerViews objectAtIndex:1] loseOneLife];
}

- (IBAction)swipeUp:(UISwipeGestureRecognizer *)sender {
    if ([(TTTWeatherCardView *)sender.view becomeChosen]) {
        if (_chosenCard != nil) {
            if (![_chosenCard isUsed]) {
                [_chosenCard becomeUnchosen];
            }
        }
        _chosenCard = (TTTWeatherCardView *)sender.view;
        //todo: send chosen card message to server here
    }
}

- (IBAction)swipeDown:(UISwipeGestureRecognizer *)sender {
    if ( [(TTTWeatherCardView *)sender.view becomeUnchosen] )
    {
        _chosenCard = nil;
        //todo: send cancel message to server
    }
}

- (void)setUsedCard  //call this when chosen card is played
{
    [_chosenCard becomeUsedAndHidden];
    _chosenCard = nil;
    [self updateWeatherCardsPosition];
}

- (void)updateWeatherCardsPosition  //rearrange position
{
    NSUInteger unplayedCardCount = [self countUnplayedCards];
    NSUInteger unplayedCardIndex = 0;
    TTTWeatherCardView * temp;
    //ori pos(left end): 72 + 64*11 = 72 + 704
    //new pos(left end): 72 + 704*i/(n-1)
    //    pos(top end): 672
    //center: +96, +144
    for (NSUInteger i = 0; i < unplayedCardCount; ++i) {
        temp = [_weatherCards objectAtIndex:i];
        if (temp != nil) {
            if ([temp isUsed]) {
                [_chosenCard setHidden:YES];    //for safety
            }
            else
            {
                [temp setCenter:
                 CGPointMake(72+704*unplayedCardIndex/(unplayedCardCount-1)+96, 672+144)];
                [temp becomeUnchosen];  //for safety
                ++unplayedCardIndex;
            }
        }
    }
}

- (NSUInteger)countUnplayedCards
{
    NSUInteger unplayedCardsCount = 0;
    for (NSUInteger i = 0; i < [_weatherCards count]; ++i) {
        if ([_weatherCards objectAtIndex:i] != nil) {
            if (![[_weatherCards objectAtIndex:i] isUsed]) {
                ++unplayedCardsCount;
            }
        }
    }
    return unplayedCardsCount;
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
