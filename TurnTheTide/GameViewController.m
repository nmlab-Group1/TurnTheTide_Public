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
    GlobalData * globalData = [GlobalData getInstance];
    [globalData.BGM_Main stop];
    [globalData.BGM_Game play];
    
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

@end
