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
@property (strong, nonatomic) NSMutableArray* roundCard;

@property (strong, nonatomic) NSMutableArray* playerLabel;

//by Roger

@property (strong, nonatomic) NSMutableArray *weatherCards;
@property (weak, atomic) TTTWeatherCardView *chosenCard;
@property (strong, nonatomic) UISwipeGestureRecognizer * tempRecog;

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
    
    //create weather cards and link to gesture recognizer by Roger
    [self initWeatherCards];
    [self initGestureOfWeatherCards];
    
    self.nowAt = 1;
    self.sendTo = @"1";
}

- (void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    self.name = [defaults objectForKey:@"Name"];
    
    self.players = [[NSMutableArray alloc] init];
    self.myCards = [[NSMutableArray alloc] init];
    self.roundCard = [[NSMutableArray alloc] init];
    self.playerLabel = [[NSMutableArray alloc] init];
    self.deck = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59", @"60", nil];

    self.gameRoomURL = [NSString stringWithFormat:@"%@/%@", GameURL, self.roomID];
    
    NSString* modeURL = [self.gameRoomURL stringByAppendingString:@"/Mode"];
    Firebase* modeFirebase = [[Firebase alloc] initWithUrl:modeURL];
    [modeFirebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot)
     {
         self.mode = snapshot.value;
     }];
    
    NSString* playerCountURL = [self.gameRoomURL stringByAppendingString:@"/Player Count"];
    Firebase* playerCountFirebase = [[Firebase alloc] initWithUrl:playerCountURL];
    [playerCountFirebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot)
     {
         self.playerCount = snapshot.value;
         for (int i=0; i<[self.playerCount integerValue]; i++)
         {
             UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80+i*40, 100, 30)];
             [nameLabel setText:@"Name"];
             [self.playerLabel addObject:nameLabel];
             [self.view addSubview:nameLabel];
         }
         for (int i=0; i<[self.playerCount integerValue]; i++)
         {
             UILabel* numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 80+i*40, 100, 30)];
             [numberLabel setText:@"Number"];
             [self.playerLabel addObject:numberLabel];
             [self.view addSubview:numberLabel];
         }
         
         NSString* playersURL = [self.gameRoomURL stringByAppendingString:@"/Players"];
         Firebase* playersFirebase = [[Firebase alloc] initWithUrl:playersURL];
         [playersFirebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot* snapshot)
          {
              [self.players addObject:snapshot.value];
              
              // setup a player here
              UILabel* nameLabel = [self.playerLabel objectAtIndex:([self.players count]-1)];
              [nameLabel setText:snapshot.value[@"Name"]];
              
              __typeof(self) __weak weakSelf = self;
              if ([self.players count] == [self.playerCount integerValue])
              {
                  [weakSelf assignDeck];
              }
          }];
     }];
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
    // NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedCompare:)];
    // self.myCards = [self.myCards sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    for (NSInteger i=0; i<12; ++i)
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTag:[[self.myCards objectAtIndex:i] integerValue]];
        [button setTitle:[self.myCards objectAtIndex:i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(cardPicked:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(20+60*i, 20, 40, 40);
        [self.view addSubview:button];
    }
}

- (void)cardPicked:(UIButton*)button
{
    if (self.nowAt == [self.sendTo integerValue])
    {
        [button setHidden:YES];
        NSString* roundURL = [NSString stringWithFormat:@"%@/Rounds/%d", self.gameRoomURL, self.nowAt];
        Firebase* sendToRound = [[Firebase alloc] initWithUrl:roundURL];
        [sendToRound updateChildValues:@{self.name: [@([button tag]) stringValue]}];
        self.sendTo = [@([self.sendTo integerValue] + 1) stringValue];
        
        [sendToRound observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot* snapshot)
         {
             [self.roundCard addObject:snapshot.value];
             
             // someone's card here
             NSLog(@" name: %@", snapshot.name);
             NSLog(@"value: %@", snapshot.value);
             for (int i=0; i<[self.playerCount integerValue]; i++)
             {
                 UILabel* label = [self.playerLabel objectAtIndex:i];
                 if ([[label text] isEqualToString:snapshot.name])
                 {
                     UILabel* numberLabel = [self.playerLabel objectAtIndex:(i+[self.playerCount integerValue])];
                     NSLog(@"numberLabel text: %@", [numberLabel text]);
                     [numberLabel setText:snapshot.value];
                     NSLog(@"new text: %@", [[self.playerLabel objectAtIndex:(i+[self.playerCount integerValue])] text]);
                     break;
                 }
             }
             
             if ([self.roundCard count] == [self.playerCount integerValue])
             {
                 [self.roundCard removeAllObjects];
                 self.nowAt++;
                 [sendToRound removeAllObservers];
             }
         }];
    }
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

//end by Roger

@end
