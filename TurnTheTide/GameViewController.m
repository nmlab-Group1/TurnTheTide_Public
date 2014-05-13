//
//  GameViewController.m
//  TurnTheTide
//
//  Created by Jimmy Lee on 14/5/7.
//  Copyright (c) 2014年 nmlab_Team1. All rights reserved.
//

#import "GameViewController.h"

#define GameURL @"https://intense-fire-739.firebaseio.com/Games"
#define RoomURL @"https://intense-fire-739.firebaseio.com/Rooms"

@interface GameViewController ()

@property (strong, nonatomic) NSString* name;

@property (strong, nonatomic) Firebase* gameFirebase;
@property (strong, nonatomic) NSString* gameRoomURL;
@property (strong, nonatomic) NSString* mode;
@property (strong, nonatomic) NSString* playerCount;
@property (strong, nonatomic) NSMutableArray* players;
@property (strong, nonatomic) NSMutableArray* deck;
@property (strong, nonatomic) NSMutableArray* myCards;

@property (nonatomic) BOOL selected;
@property (nonatomic) NSInteger nowAt;
@property (strong, nonatomic) NSString* sendTo;
@property (strong, nonatomic) NSMutableDictionary* roundCard;
@property (strong, nonatomic) NSMutableArray* tideCards;
@property (nonatomic) NSInteger life;
@property (strong, nonatomic) NSString* tides1;
@property (strong, nonatomic) NSString* tides2;

@property (strong, nonatomic) NSMutableArray *playerViews;
@property (strong, nonatomic) NSMutableDictionary* playerLife;

//by Roger

@property (strong, nonatomic) NSMutableArray *weatherCards;
@property (weak, atomic) TTTWeatherCardView *chosenCard;
@property (strong, nonatomic) UISwipeGestureRecognizer * tempRecog;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingImage;
@property (weak, nonatomic) IBOutlet UILabel *connectingLabel;
@property (nonatomic) BOOL canPlay;

//end by Roger

@end

@implementation GameViewController

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
    
    //play music by Roger
    GlobalData * globalData = [GlobalData getInstance];
    [globalData.BGM_Main stop];
    [globalData.BGM_Game play];

    self.nowAt = 1;
    self.sendTo = @"1";
    _canPlay = NO;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"mainBG"]]];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    self.name = [defaults objectForKey:@"Name"];
    
    self.playerLife = [[NSMutableDictionary alloc] init];
    
    self.players = [[NSMutableArray alloc] init];
    self.myCards = [[NSMutableArray alloc] init];
    self.roundCard = [[NSMutableDictionary alloc] init];
    self.tideCards = [[NSMutableArray alloc] init];
    self.deck = [[NSMutableArray alloc] initWithObjects:@"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59", @"60", nil];

    self.gameRoomURL = [NSString stringWithFormat:@"%@/%@", GameURL, self.roomID];
    
    NSString* modeURL = [self.gameRoomURL stringByAppendingString:@"/Mode"];
    Firebase* modeFirebase = [[Firebase alloc] initWithUrl:modeURL];
    [modeFirebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot)
     {
         self.mode = snapshot.value;
     }];
    
    NSString* tideURL = [self.gameRoomURL stringByAppendingString:@"/Tide"];
    Firebase* tideFirebase = [[Firebase alloc] initWithUrl:tideURL];
    [tideFirebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot* snapshot)
     {
         [self.tideCards addObject:snapshot.value];
     }];
    
    NSString* playerCountURL = [self.gameRoomURL stringByAppendingString:@"/Player Count"];
    Firebase* playerCountFirebase = [[Firebase alloc] initWithUrl:playerCountURL];
    [playerCountFirebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot)
     {
         self.playerCount = snapshot.value;
         
         NSString* playersURL = [self.gameRoomURL stringByAppendingString:@"/Players"];
         Firebase* playersFirebase = [[Firebase alloc] initWithUrl:playersURL];
         [playersFirebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot* snapshot)
          {
              [self.players addObject:snapshot.value];
              
              // setup a player here
              __typeof(self) __weak weakSelf = self;
              if ([self.players count] == [self.playerCount integerValue])
              {
                  [weakSelf assignDeck];
              }
          }];
     }];
}

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

- (void)assignDeck
{
    NSInteger index;
    for (NSInteger i=0; i<[self.players count]; i++)
    {
        NSDictionary* dic = [self.players objectAtIndex:i];
        if ([dic[@"Name"] isEqualToString:self.name])
        {
            index = i;
            break;
        }
    }
    
    NSInteger order = [[self.players objectAtIndex:index][@"Order"] integerValue];
    
    NSString* deckURL = [self.gameRoomURL stringByAppendingString:@"/Deck"];
    
    if ([self.deck count] % [self.playerCount integerValue] == order)
    {
        NSInteger pick = arc4random() % [self.deck count];
        NSString* pickedCard = [self.deck objectAtIndex:pick];
        
        [self.deck removeObjectAtIndex:pick];
        [self.myCards addObject:pickedCard];
        NSString* pickURL = [NSString stringWithFormat:@"%@/%@", deckURL, pickedCard];
        Firebase* pickFirebase = [[Firebase alloc] initWithUrl:pickURL];
        [pickFirebase removeValue];
    }
    
    Firebase* deckFirebase = [[Firebase alloc] initWithUrl:deckURL];
    [deckFirebase observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot* snapshot)
     {
         // removed card is here
         [self.deck removeObject:snapshot.value];
         
         if ([self.myCards count] == 12)
         {
             [deckFirebase removeAllObservers];
             [self initGame];
         }
         
         else if ([self.deck count] % [self.playerCount integerValue] == order)
         {
             NSInteger pick = arc4random() % [self.deck count];
             NSString* pickedCard = [self.deck objectAtIndex:pick];
             
             [self.deck removeObjectAtIndex:pick];
             [self.myCards addObject:pickedCard];
             NSString* pickURL = [NSString stringWithFormat:@"%@/%@", deckURL, pickedCard];
             Firebase* pickFirebase = [[Firebase alloc] initWithUrl:pickURL];
             [pickFirebase removeValue];
         }
     }];
}

- (void)initGame
{
    self.myCards = [self.myCards sortedArrayUsingSelector:@selector(compare:)];
    
    [_loadingImage setHidden:YES];
    [_connectingLabel setHidden:YES];
    _canPlay = YES;
    
    //create weather cards and link to gesture recognizer by Roger
    [self initWeatherCards];
    [self initGestureOfWeatherCards];
    
    double tLife = 0;
    for (NSInteger i=0; i<12; ++i)
    {
        TTTWeatherCardView* card = [_weatherCards objectAtIndex:i];
        [card setWithRank:[[self.myCards objectAtIndex:i] integerValue]];
        // convert rank to life
        tLife += [card getLife];
    }
    
    self.life = tLife;
    NSString* lifeURL = [self.gameRoomURL stringByAppendingString:@"/Life"];
    // send life
    Firebase* lifeFirebase = [[Firebase alloc] initWithUrl:lifeURL];
    [lifeFirebase updateChildValues:@{self.name:[NSString stringWithFormat:@"%d", self.life]}];
    
    // get all life, display
    __block NSInteger count = 0;
    [lifeFirebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot* snapshot)
     {
         [self.playerLife addEntriesFromDictionary:@{snapshot.name:snapshot.value}];
         count++;
         if (count == [self.playerCount integerValue])
         {
             [self initPlayerViews];
         }
     }];
    
    NSDictionary* dic = [self.tideCards objectAtIndex:0];
    self.tides1 = dic[@"t1"];
    self.tide1.image = [UIImage imageNamed:[NSString stringWithFormat:@"TideCard_%@", self.tides1]];
    self.tides2 = dic[@"t2"];
    self.tide2.image = [UIImage imageNamed:[NSString stringWithFormat:@"TideCard_%@", self.tides2]];
}

- (void)cardPicked:(UIButton*)button
{
    
}

//by Roger
/*
- (void)viewDidLayoutSubviews
{
    for (int i = 0; i < 12; ++i) {
        [[_weatherCards objectAtIndex:i] setCenter:CGPointMake(72+96+64*i, 672+144)];
    }
}
*/
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

- (IBAction)swipeUp:(UISwipeGestureRecognizer *)sender {
    if (!_canPlay) {
    }
    else if ([(TTTWeatherCardView *)sender.view becomeChosen]) {
        if (_chosenCard != nil) {
            if (![_chosenCard isUsed]) {
                [_chosenCard becomeUnchosen];
            }
        }
        _chosenCard = (TTTWeatherCardView *)sender.view;
    }
    else {
        // send card here
        _canPlay = NO;
        
        if (self.nowAt == [self.sendTo integerValue])
        {
            NSString* roundURL = [NSString stringWithFormat:@"%@/Rounds/%d", self.gameRoomURL, self.nowAt];
            Firebase* sendToRound = [[Firebase alloc] initWithUrl:roundURL];
            [sendToRound updateChildValues:@{self.name:[NSString stringWithFormat:@"%d", [_chosenCard getRank]]}];
            [self setUsedCard];
            self.sendTo = [@([self.sendTo integerValue] + 1) stringValue];
            
            [sendToRound observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot* snapshot)
             {
                 [self.roundCard addEntriesFromDictionary:@{snapshot.name:snapshot.value}];
                 
                 // someone's card here
                 
                 for (TTTPlayerView* playerView in self.playerViews)
                 {
                     if ([[playerView getName] isEqualToString:snapshot.name])
                     {
                         if ([snapshot.name isEqualToString:self.name])
                         {
                             [playerView setCardRankAndShow:[snapshot.value integerValue] upsideDown:NO];
                         }
                         else
                         {
                             [playerView setCardRankAndShow:[snapshot.value integerValue] upsideDown:YES];
                         }
                     }
                 }
                 
                 if ([[self.roundCard allKeys] count] == [self.playerCount integerValue])
                 {
                     // assign tide here
                     NSInteger tideBig, tideSmall;
                     tideBig = tideSmall = [self.tides1 integerValue];
                     if ([self.tides2 integerValue] > tideBig)
                     {
                         tideBig = [self.tides2 integerValue];
                     }
                     else
                     {
                         tideSmall = [self.tides2 integerValue];
                     }
                     
                     NSInteger first = 0, second = 0;
                     NSString *firstS, *secondS;
                     firstS = [[NSString alloc] init];
                     secondS = [[NSString alloc] init];
                     for (NSInteger i=0; i<[self.players count]; i++)
                     {
                         NSDictionary* dic = [self.players objectAtIndex:i];
                         NSString* thisName = dic[@"Name"];
                         
                         NSInteger thisNum = [self.roundCard[thisName] integerValue];
                         if (thisNum > first)
                         {
                             second = first;
                             secondS = firstS;
                             first = thisNum;
                             firstS = thisName;
                         }
                         else if (thisNum > second)
                         {
                             second = thisNum;
                             secondS = thisName;
                         }
                     }
                     
                     int tide = -1;
                     for (TTTPlayerView* playerView in self.playerViews)
                     {
                         if ([[playerView getName] isEqualToString:firstS])
                         {
                             [playerView setTide:tideSmall];
                         }
                         else if ([[playerView getName] isEqualToString:secondS])
                         {
                             [playerView setTide:tideBig];
                         }
                         
                         NSLog(@"%d", [playerView getTide]);
                         
                         if ([playerView getTide] > tide)
                             tide = [playerView getTide];
                     }
                     
                     NSLog(@"  %d", tide);
                     
                     //delay a few seconds
                     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.5*NSEC_PER_SEC);
                     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                         for (TTTPlayerView* playerView in self.playerViews)
                         {
                             if ([playerView getTide] == tide)
                             {
                                 [playerView loseOneLife];
                             }
                         }
                     
                         [self.roundCard removeAllObjects];
                         [sendToRound removeAllObservers];
                     
                     
                         self.nowAt++;
                         
                         //reset playerViews' played card
                         for (int i = 0; i < [_playerCount integerValue]; ++i) {
                             [[_playerViews objectAtIndex:i] setHasPlayed:NO];
                         }
                         
                         // new round
                         if (self.nowAt == 13)
                         {
                             [NSThread sleepForTimeInterval:5];
                             [self.navigationController popViewControllerAnimated:YES];
                         }
                         else
                         {
                             //delay a few seconds
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.5*NSEC_PER_SEC);
                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                 
                                 NSDictionary* dic = [self.tideCards objectAtIndex:(self.nowAt-1)];
                                 self.tides1 = dic[@"t1"];
                                 self.tides2 = dic[@"t2"];
                                 [_tide1 setAlpha:0.0];
                                 [_tide2 setAlpha:0.0];
                                 self.tide1.image = [UIImage imageNamed:[NSString stringWithFormat:@"TideCard_%@", self.tides1]];
                                 self.tide2.image = [UIImage imageNamed:[NSString stringWithFormat:@"TideCard_%@", self.tides2]];
                                 
                                 [UIView animateWithDuration:0.5 animations:^{
                                     [_tide1 setAlpha:1.0];
                                     [_tide2 setAlpha:1.0];
                                 }];
                                 
                                 _canPlay = YES;
                             });
                         }
                    });
                 }
             }];
        }
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
    [UIView setAnimationDelay:0.25];
    
    for (NSUInteger i = 0; i < HAND_COUNT; ++i) {
        temp = [_weatherCards objectAtIndex:i];
        if (temp != nil) {
            if ([temp isUsed]) {
                [_chosenCard setHidden:YES];    //for safety
            }
            else
            {
                if (unplayedCardCount == 1) {
                    [temp setCenter:
                     CGPointMake(512, 672+144)];
                    [temp becomeUnchosen];  //for safety
                    break;
                }
                else {
                    [temp setCenter:
                     CGPointMake(72+704*unplayedCardIndex/(unplayedCardCount-1)+96, 672+144)];
                    [temp becomeUnchosen];  //for safety
                    ++unplayedCardIndex;
                }
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

- (void)initPlayerViews
{
    int playerCount = [self.playerCount integerValue];
    int intervalX = (1024 - (playerCount-1) * PLAYER_VIEW_WIDTH)/(playerCount);
    int offsetY = 16;
    int otherPlayerCount = 0;
    _playerViews = [[NSMutableArray alloc] init];
    TTTPlayerView *temp;
    
    for (int i = 0; i < playerCount; ++i) {
        NSDictionary* dic = [self.players objectAtIndex:i];
        NSString* name = dic[@"Name"];
        
        if ([name isEqualToString:self.name]) {
            temp = [[TTTPlayerView alloc] initWithFrame:CGRectMake(800, 500, PLAYER_VIEW_WIDTH, PLAYER_VIEW_HEIGHT)];
            [temp setNameAndLife:name life:[self.playerLife[name] integerValue]];
            [_playerViews addObject:temp];
            [self.view addSubview:temp];
        }
        else
        {
            temp = [[TTTPlayerView alloc] initWithFrame:CGRectMake(intervalX*(otherPlayerCount+1) + PLAYER_VIEW_WIDTH*otherPlayerCount, offsetY, PLAYER_VIEW_WIDTH, PLAYER_VIEW_HEIGHT)];
            [temp setNameAndLife:name life:[self.playerLife[name] integerValue]];
            [_playerViews addObject:temp];
            [self.view addSubview:temp];
            ++otherPlayerCount;
        }
    }
}

//end by Roger

@end
