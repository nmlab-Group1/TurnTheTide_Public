//
//  RoomViewController.h
//  TurnTheTide
//
//  Created by Roger on 4/27/14.
//  Copyright (c) 2014 nmlab_Team1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>

@interface RoomViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray* rooms;
@property (strong, nonatomic) Firebase* firebase;
@property (strong, nonatomic) NSString* name;

@property (weak, nonatomic) IBOutlet UITableView *roomsTableView;
@property (weak, nonatomic) IBOutlet UILabel *playerCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
