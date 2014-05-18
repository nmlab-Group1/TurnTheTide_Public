//
//  RoomViewController.m
//  TurnTheTide
//
//  Created by Roger on 4/27/14.
//  Copyright (c) 2014 nmlab_Team1. All rights reserved.
//

#import "RoomViewController.h"
#import "RoomTableViewCell.h"
#import "GameViewController.h"

#define GameURL @"https://intense-fire-739.firebaseio.com/Games"
#define RoomURL @"https://intense-fire-739.firebaseio.com/Rooms"

@interface RoomViewController ()

@property (strong, nonatomic) Firebase* roomFirebase;
@property (strong, nonatomic) NSMutableArray* rooms;
@property (strong, nonatomic) NSMutableArray* roomIDs;
@property (strong, nonatomic) NSString* selectedRoomID;
@property (strong, nonatomic) NSMutableDictionary* room;
@property (strong, nonatomic) NSMutableDictionary* localRooms;

@end

@implementation RoomViewController

@synthesize roomsTableView, playerCountLabel, modeLabel, nameLabel, localRooms;

- (IBAction)navigationBack:(UIButton *)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

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
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    nameLabel.text = [defaults valueForKey:@"Name"];
    roomsTableView.rowHeight = 84;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"mainBG"]]];
    
    
    self.rooms = [[NSMutableArray alloc] init];
    localRooms = [[NSMutableDictionary alloc] init];
    self.roomIDs = [[NSMutableArray alloc] init];
    self.room = [[NSMutableDictionary alloc] init];
    
    self.roomFirebase = [[Firebase alloc] initWithUrl:RoomURL];
    [self.roomFirebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot* snapshot)
     {
         [self.roomIDs addObject:snapshot.name];
         [self.rooms addObject:snapshot.value];
         
         [self.room addEntriesFromDictionary:@{snapshot.name:snapshot.value}];
         localRooms = self.room;
         
         [self.roomsTableView reloadData];
     }];
    [self.roomFirebase observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot* snapshot)
     {
         [self.roomIDs removeObject:snapshot.name];
         [self.roomIDs addObject:snapshot.name];
         [self.rooms removeObject:snapshot.value];
         [self.rooms addObject:snapshot.value];
         
         [self.room removeObjectForKey:snapshot.name];
         [self.room setValue:snapshot.value forKey:snapshot.name];
         localRooms = self.room;
         
         [self.roomsTableView reloadData];
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"roomToGame"])
    {
        GameViewController* controller = (GameViewController*)segue.destinationViewController;
        controller.roomID = self.selectedRoomID;
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[localRooms allKeys] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"RoomTableViewCellIdentifier";
    RoomTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RoomTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSString* ID = [[localRooms allKeys] objectAtIndex:indexPath.row];
    NSDictionary* roomContent = localRooms[ID];
    
    NSString* playerCount = roomContent[@"Player Count"];
    NSString* need = roomContent[@"Need"];
    playerCount = [playerCount stringByAppendingString:@".png"];
    need = [need stringByAppendingString:@".png"];
    
    cell.playerCountImageView.image = [UIImage imageNamed:playerCount];
    cell.needCountImageView.image = [UIImage imageNamed:need];
    cell.ownerLabel.text = roomContent[@"Owner"];
    cell.modeLabel.text = roomContent[@"Mode"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRoomID = [[localRooms allKeys] objectAtIndex:indexPath.row];

    NSString* roomID = [[localRooms allKeys] objectAtIndex:indexPath.row];
    NSString* roomNeed = [NSString stringWithFormat:@"/%@/Need", roomID];
    NSString* needPath = [RoomURL stringByAppendingString:roomNeed];
    NSString* playersPath = [NSString stringWithFormat:@"%@/%@/Players", GameURL, roomID];
    
    Firebase* needFirebase = [[Firebase alloc] initWithUrl:needPath];
    [needFirebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot)
     {
         NSInteger order = [snapshot.value integerValue];
         
         if ([snapshot.value isEqualToString:@"0"])
         {
             UIAlertView* unableToJoin = [[UIAlertView alloc] initWithTitle:@"Unable to Join Room" message:@"Room is full now" delegate:nil cancelButtonTitle:@"Got it" otherButtonTitles:nil];
             [unableToJoin show];
         }
         else
         {
             [[self.roomFirebase childByAppendingPath:roomNeed] setValue:[@(order - 1) stringValue]];
             Firebase* playerFirebase = [[Firebase alloc] initWithUrl:playersPath];
             [[playerFirebase childByAutoId] setValue:@{@"Name":[nameLabel text], @"Order":[@(order - 1) stringValue]}];
             
             [self performSegueWithIdentifier:@"roomToGame" sender:nil];
         }
     }];
}

#pragma mark - choose, find and create

- (IBAction)choosePlayerCount:(id)sender
{
    if ([sender tag] == 0)
    {
        playerCountLabel.text = @"All";
    }
    else
    {
        playerCountLabel.text = [@([sender tag]) stringValue];
    }
}

- (IBAction)chooseMode:(id)sender
{
    if ([sender tag] == 0)
    {
        modeLabel.text = @"All";
    }
    else if ([sender tag] == 1)
    {
        modeLabel.text = @"One";
    }
    else if ([sender tag] == 2)
    {
        modeLabel.text = @"Full";
    }
}

- (IBAction)findRoom:(id)sender
{
    localRooms = self.room;
    
    NSMutableDictionary* tempArray1 = [[NSMutableDictionary alloc] init];
    NSArray* allKeys1 = [localRooms allKeys];
    // NSLog(@"count %d", [allKeys1 count]);
    
    if (![[playerCountLabel text] isEqualToString:@"All"])
    {
        for (NSString* key in allKeys1)
        {
            NSDictionary* dic = localRooms[key];
            // NSLog(@"%@", dic[@"Player Count"]);
            if ([dic[@"Player Count"] isEqualToString:[playerCountLabel text]])
            {
                [tempArray1 addEntriesFromDictionary:@{key:localRooms[key]}];
            }
        }
    }
    else
    {
        tempArray1 = localRooms;
    }
    
    NSMutableDictionary* tempArray2 = [[NSMutableDictionary alloc] init];
    NSArray* allKeys2 = [tempArray1 allKeys];
    // NSLog(@"count: %d", [allKeys2 count]);
    
    if (![[modeLabel text] isEqualToString:@"All"])
    {
        for (NSString* key in allKeys2)
        {
            NSDictionary* dic = tempArray1[key];
            // NSLog(@"%@", dic[@"Mode"]);
            if ([dic[@"Mode"] isEqualToString:[modeLabel text]])
            {
                [tempArray2 addEntriesFromDictionary:@{key:tempArray1[key]}];
            }
        }
    }
    else
    {
        tempArray2 = tempArray1;
    }
    
    localRooms = tempArray2;
    [roomsTableView reloadData];
}

- (IBAction)createRoom:(id)sender
{
    if (![[playerCountLabel text] isEqualToString:@"All"] && ![[modeLabel text] isEqualToString:@"All"])
    {
        Firebase* child = [self.roomFirebase childByAutoId];
        [child setValue:@{@"Owner":[nameLabel text], @"Mode":modeLabel.text, @"Player Count":playerCountLabel.text, @"Need":playerCountLabel.text}];
        Firebase* gameFirebase = [[Firebase alloc] initWithUrl:GameURL];
        NSString* childPath = [NSString stringWithFormat:@"/%@", child.name];
        NSString* deckPath = [NSString stringWithFormat:@"/%@/Deck", child.name];
        NSString* tidePath = [NSString stringWithFormat:@"/%@/Tide", child.name];
        
        [[gameFirebase childByAppendingPath:childPath] updateChildValues:@{@"Mode":modeLabel.text, @"Player Count":playerCountLabel.text}];
        
        [[gameFirebase childByAppendingPath:deckPath] updateChildValues:@{@"01":@"01", @"02":@"02", @"03":@"03", @"04":@"04", @"05":@"05", @"06":@"06", @"07":@"07", @"08":@"08", @"09":@"09", @"10":@"10", @"11":@"11", @"12":@"12", @"13":@"13", @"14":@"14", @"15":@"15", @"16":@"16", @"17":@"17", @"18":@"18", @"19":@"19", @"20":@"20", @"21":@"21", @"22":@"22", @"23":@"23", @"24":@"24", @"25":@"25", @"26":@"26", @"27":@"27", @"28":@"28", @"29":@"29", @"30":@"30", @"31":@"31", @"32":@"32", @"33":@"33", @"34":@"34", @"35":@"35", @"36":@"36", @"37":@"37", @"38":@"38", @"39":@"39", @"40":@"40", @"41":@"41", @"42":@"42", @"43":@"43", @"44":@"44", @"45":@"45", @"46":@"46", @"47":@"47", @"48":@"48", @"49":@"49", @"50":@"50", @"51":@"51", @"52":@"52", @"53":@"53", @"54":@"54", @"55":@"55", @"56":@"56", @"57":@"57", @"58":@"58", @"59":@"59", @"60":@"60"}];
        
        NSMutableArray* tideArray = [NSMutableArray arrayWithObjects:@"1", @"1", @"2", @"2", @"3", @"3", @"4", @"4", @"5", @"5", @"6", @"6", @"7", @"7", @"8", @"8", @"9", @"9", @"10", @"10", @"11", @"11", @"12", @"12", nil];
        NSMutableDictionary* tideDic = [[NSMutableDictionary alloc] init];
        for (NSInteger i=1; i<=12; i++)
        {
            NSString* num = [NSString stringWithFormat:@"%d", i];
            NSInteger choose = arc4random() % [tideArray count];
            NSString* tide1 = [tideArray objectAtIndex:choose];
            [tideArray removeObjectAtIndex:choose];
            choose = arc4random() % [tideArray count];
            NSString* tide2 = [tideArray objectAtIndex:choose];
            [tideArray removeObjectAtIndex:choose];
            NSDictionary* dic = @{num:@{@"t1":tide1, @"t2":tide2}};
            [tideDic addEntriesFromDictionary:dic];
        }
        [[gameFirebase childByAppendingPath:tidePath] updateChildValues:tideDic];
    }
}

@end
