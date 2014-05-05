//
//  MainViewController.m
//  TurnTheTide
//
//  Created by Roger on 4/26/14.
//  Copyright (c) 2014 nmlab_Team1. All rights reserved.
//

#import "MainViewController.h"
#import "RoomViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"mainToRoom"])
    {
        RoomViewController* controller = (RoomViewController*)segue.destinationViewController;
        controller.name = self.name;
    }
}

@end
