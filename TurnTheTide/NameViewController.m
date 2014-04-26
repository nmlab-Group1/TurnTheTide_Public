//
//  NameViewController.m
//  TurnTheTide
//
//  Created by Roger on 4/15/14.
//  Copyright (c) 2014 nmlab_Team1. All rights reserved.
//

#import "NameViewController.h"

@interface NameViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation NameViewController
- (IBAction)naviForward:(id)sender {
}

- (IBAction)DidEndOnExit:(UITextField *)sender {
    [self.nameLabel setText: [sender text]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
