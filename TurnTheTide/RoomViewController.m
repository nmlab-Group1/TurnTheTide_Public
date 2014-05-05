//
//  RoomViewController.m
//  TurnTheTide
//
//  Created by Roger on 4/27/14.
//  Copyright (c) 2014 nmlab_Team1. All rights reserved.
//

#import "RoomViewController.h"
#import "RoomTableViewCell.h"

#define RoomURL @"https://intense-fire-739.firebaseio.com/Rooms"

@interface RoomViewController ()

@property (strong, nonatomic) NSMutableArray* localRooms;

@end

@implementation RoomViewController

@synthesize roomsTableView, playerCountLabel, modeLabel, nameLabel, localRooms;

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
    self.rooms = [[NSMutableArray alloc] init];
    localRooms = [[NSMutableArray alloc] init];
    self.firebase = [[Firebase alloc] initWithUrl:RoomURL];
    [self.firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot* snapshot)
     {
         [self.rooms addObject:snapshot.value];
         localRooms = self.rooms;
         [self.roomsTableView reloadData];
     }];
    nameLabel.text = self.name;
    roomsTableView.rowHeight = 81;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [localRooms count];
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
    
    NSDictionary* roomContent = [localRooms objectAtIndex:indexPath.row];
    
    NSString* playerCount = roomContent[@"Player Count"];
    playerCount = [playerCount stringByAppendingString:@".png"];
    
    cell.playerCountImageView.image = [UIImage imageNamed:playerCount];
    cell.ownerLabel.text = roomContent[@"Owner"];
    cell.modeLabel.text = roomContent[@"Mode"];

    return cell;
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
    NSMutableArray* tempArray1 = [[NSMutableArray alloc] init];

    if (![[playerCountLabel text] isEqualToString:@"All"])
    {
        for (NSDictionary* object in self.rooms)
        {
            if ([object[@"Player Count"] isEqualToString:[playerCountLabel text]])
            {
                [tempArray1 addObject:object];
            }
        }
    }
    else
    {
        tempArray1 = self.rooms;
    }

    NSMutableArray* tempArray2 = [[NSMutableArray alloc] init];
    
    if (![[modeLabel text] isEqualToString:@"All"])
    {
        for (NSDictionary* object in tempArray1)
        {
            if ([object[@"Mode"] isEqualToString:[modeLabel text]])
            {
                [tempArray2 addObject:object];
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
        [[self.firebase childByAutoId] setValue:@{@"Owner":self.name, @"Mode":modeLabel.text, @"Player Count":playerCountLabel.text}];
    }
}

@end
