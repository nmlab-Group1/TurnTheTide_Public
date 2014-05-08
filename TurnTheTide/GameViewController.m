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

@property (strong, nonatomic) Firebase* gameFirebase;
@property (strong, nonatomic) NSString* gameRoomURL;
@property (strong, nonatomic) NSString* mode;
@property (strong, nonatomic) NSString* playerCount;
@property (strong, nonatomic) NSMutableArray* players;
@property (strong, nonatomic) NSMutableArray* deck;
@property (strong, nonatomic) NSMutableArray* myCards;

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
}

- (void)viewWillAppear:(BOOL)animated
{
    self.players = [[NSMutableArray alloc] init];
    self.myCards = [[NSMutableArray alloc] init];
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
         
         NSString* playersURL = [self.gameRoomURL stringByAppendingString:@"/Players"];
         Firebase* playersFirebase = [[Firebase alloc] initWithUrl:playersURL];
         [playersFirebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot* snapshot)
          {
              [self.players addObject:snapshot.value];
              
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
    NSDictionary* dic = [self.players objectAtIndex:index];
    
    NSString* deckURL = [self.gameRoomURL stringByAppendingString:@"/Deck"];
    
    if ([self.deck count] % [self.playerCount integerValue] == [dic[@"Order"] integerValue])
    {
        NSInteger pick = arc4random() % [self.deck count];
        NSString* pickedCard = [self.deck objectAtIndex:pick];
        
        NSLog(@"%@ picked %@", self.name, pickedCard);
        
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
         if ([self.deck count] % [self.playerCount integerValue] == [dic[@"Order"] integerValue] && [self.myCards count] != 12)
         {
             NSInteger pick = arc4random() % [self.deck count];
             NSString* pickedCard = [self.deck objectAtIndex:pick];
             
             NSLog(@"%@ picked %@", self.name, pickedCard);
             
             [self.deck removeObjectAtIndex:pick];
             [self.myCards addObject:pickedCard];
             NSString* pickURL = [NSString stringWithFormat:@"%@/%@", deckURL, pickedCard];
             Firebase* pickFirebase = [[Firebase alloc] initWithUrl:pickURL];
             [pickFirebase removeValue];
         }
     }];
}

@end
