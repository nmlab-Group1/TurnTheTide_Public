//
//  NameViewController.m
//  TurnTheTide
//
//  Created by Roger on 4/15/14.
//  Copyright (c) 2014 nmlab_Team1. All rights reserved.
//

#import "NameViewController.h"
#import "MainViewController.h"

@interface NameViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation NameViewController
- (IBAction)naviForward:(id)sender {
}

- (IBAction)DidEndOnExit:(UITextField *)sender {
    NSString *trimmedName = [sender.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    int returnValue = 0;
    if ( [trimmedName length] <= 0 )
    {
        UIAlertView *blankAlert = [[UIAlertView alloc]
                                   initWithTitle:@"register error"
                                   message:@"Please input your name to rigister" delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [blankAlert show];
    }
    else if ([trimmedName length] > 15)
    {
        UIAlertView *lengthAlert = [[UIAlertView alloc]
                                   initWithTitle:@"register error"
                                   message:@"The name should be less than 16 characters." delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [lengthAlert show];
    }
    else
    {
        returnValue = [self registerName:[sender text]];
        if(returnValue == 0)
        {
            [self performSegueWithIdentifier:@"pushToMain" sender:self];
        }
        else if (returnValue == 1)
        {
            
        }
    }
//    MainViewController *mainVC = [[MainViewController alloc] initWithNibName:@"mainVC" bundle:nil];
//    [self.navigationController pushViewController: mainVC animated:YES];
}

- (int)registerName:(NSString *)nameString
{
    return 0;
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
