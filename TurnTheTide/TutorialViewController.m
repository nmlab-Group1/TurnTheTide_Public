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

@property (nonatomic) int counter;

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
    [self setSelfView];
    [[_playerViews objectAtIndex:3] setCardRankAndShow:3 upsideDown:NO];
    NSLog(@"%d", [_playerViews count]);
    
    _counter = 0;
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
    [self timer];
//    [self showResult];
//    [[_playerViews objectAtIndex:1] loseOneLife];
//    [[_playerViews objectAtIndex:1] setTide:12];
//    [[_weatherCards objectAtIndex:(arc4random()%HAND_COUNT)] becomeUsedAndHidden];
//    [self updateWeatherCardsPosition];
/*
    if (_counter == 0) {
        [[_playerViews objectAtIndex:1] setHasPlayed:YES];
        _counter = 1;
    }
    else if (_counter == 1) {
        [[_playerViews objectAtIndex:1] setCardRankAndShow:34 upsideDown:YES];
    }
*/
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
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];

    for (NSUInteger i = 0; i < HAND_COUNT; ++i) {
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
    
    [UIView commitAnimations];
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

- (void)showResult  //with end game buttons
{
    UIView *resultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [resultView setBackgroundColor:[UIColor blackColor]];
    [resultView setAlpha:0.5];

    UIView *resultBoard = [[UIView alloc] initWithFrame:CGRectMake(256, -512, 512, 512)];
    [resultBoard setBackgroundColor:[UIColor colorWithRed:0.0 green:0.25 blue:0.0 alpha:1.0]];
    [resultBoard setOpaque:1];
    //[resultBoard setImage: [UIImage imageNamed:@"woodBoard"]];
    
    UILabel *resultLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 16, 512, 48)];
    resultLabel.text = @"Result";
    resultLabel.textColor = [UIColor whiteColor];
    resultLabel.font = [UIFont fontWithName:@"Chalkduster" size:32.0];
    resultLabel.textAlignment = NSTextAlignmentCenter;
    [resultBoard addSubview:resultLabel];
    
    UIButton *yesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //[[UIButton alloc] initWithFrame:CGRectMake(0, 448, 256, 64)];
    yesButton.frame = CGRectMake(0, 448, 256, 64);
    [yesButton setTitle:@"OK" forState:UIControlStateNormal];
    [yesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    yesButton.titleLabel.font = [UIFont fontWithName:@"Chalkduster" size:32.0];
    [yesButton addTarget:self
                  action:@selector(navigationBack:)
        forControlEvents:UIControlEventTouchUpInside];
    [resultBoard addSubview:yesButton];
    
    UIButton *noButton = [[UIButton alloc] initWithFrame:CGRectMake(256, 448, 256, 64)];
    [noButton setTitle:@"Damn It" forState:UIControlStateNormal];
    [noButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    noButton.titleLabel.font = [UIFont fontWithName:@"Chalkduster" size:32.0];
    [noButton addTarget:self
                 action:@selector(endGame:)
       forControlEvents:UIControlEventTouchUpInside];
    [resultBoard addSubview:noButton];
    
    UILabel *tempPlayerLabel;
    for (int i = 0; i < 3; ++i) {
        tempPlayerLabel = [[UILabel alloc]initWithFrame:CGRectMake(32, 80+48*i, 448, 48)];
        tempPlayerLabel.text = [[_playerViews objectAtIndex:i] getName];
        tempPlayerLabel.textColor = [UIColor whiteColor];
        tempPlayerLabel.font = [UIFont fontWithName:@"Chalkduster" size:24.0];
        tempPlayerLabel.textAlignment = NSTextAlignmentLeft;
        [resultBoard addSubview:tempPlayerLabel];
        
        tempPlayerLabel = [[UILabel alloc]initWithFrame:CGRectMake(32, 80+48*i, 448, 48)];
        tempPlayerLabel.text = [@([[_playerViews objectAtIndex:i] getCurrentLifeNum]) stringValue];
        tempPlayerLabel.textColor = [UIColor whiteColor];
        tempPlayerLabel.font = [UIFont fontWithName:@"Chalkduster" size:24.0];
        tempPlayerLabel.textAlignment = NSTextAlignmentRight;
        [resultBoard addSubview:tempPlayerLabel];
    }
    
    [self.view addSubview:resultView];
    [self.view addSubview:resultBoard];
    
    [UIView animateWithDuration:0.5 animations:^{
        [resultBoard setCenter:CGPointMake(512, 384)];
    }];
}

- (void)setSelfView
{
    TTTPlayerView * temp = [[TTTPlayerView alloc] initWithFrame:CGRectMake(800, 400, PLAYER_VIEW_WIDTH, PLAYER_VIEW_HEIGHT)];
    [temp setNameAndLife:@"self" life:9];
    [_playerViews addObject:temp];
    [self.view addSubview:temp];
}

- (IBAction)endGame:(UIButton *)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)timer
{
/*    [UIView animateWithDuration:5.0 animations:^{
        [[_playerViews objectAtIndex:3] setCenter:CGPointMake(800, 100)];
    }];
*/
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.5*NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

//    });

    [self performSelector:@selector(back:) withObject:nil afterDelay:5.0];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Tutorial


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
