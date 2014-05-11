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
@property (strong, nonatomic) NSMutableArray* names;

@end

@implementation NameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"mainBG"]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.names = [[NSMutableArray alloc] init];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"Name"])
    {
        [self performSegueWithIdentifier:@"pushToMain" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)naviForward:(id)sender {
}

- (IBAction)DidEndOnExit:(UITextField *)sender
{
    [sender resignFirstResponder];
    
    NSString *trimmedName = [sender.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( [trimmedName length] <= 0 )
    {
        UIAlertView *blankAlert = [[UIAlertView alloc] initWithTitle:@"register error" message:@"Please input your name to rigister" delegate:nil cancelButtonTitle:@"OK"  otherButtonTitles:nil];
        [blankAlert show];
    }
    else if ([trimmedName length] > 15)
    {
        UIAlertView *lengthAlert = [[UIAlertView alloc] initWithTitle:@"register error" message:@"The name should be less than 16 characters." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [lengthAlert show];
    }
    else
    {
        NSString* nameCountURL = @"https://intense-fire-739.firebaseio.com/Name Count";
        Firebase* nameCountFirebase = [[Firebase alloc] initWithUrl:nameCountURL];
        [nameCountFirebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot)
         {
             NSInteger count = [snapshot.value integerValue];
             
             NSString* NamesURL = @"https://intense-fire-739.firebaseio.com/Names";
             Firebase* nameFirebase = [[Firebase alloc] initWithUrl:NamesURL];
             if (count)
             {
                 [self.names removeAllObjects];
                 [nameFirebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot* snapshot)
                  {
                      [self.names addObject:snapshot.value];
                  
                      if ([self.names count] == count)
                      {
                          BOOL legal = YES;
                          for (NSDictionary* dic in self.names)
                          {
                              if ([dic[@"Name"] isEqualToString:[sender text]])
                              {
                                  legal = NO;
                                  break;
                              }
                          }
                      
                          if (legal)
                          {
                              NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                              [defaults setValue:[sender text] forKey:@"Name"];
                              [defaults synchronize];
                          
                              [nameCountFirebase removeAllObservers];
                              [nameFirebase removeAllObservers];
                              [nameCountFirebase setValue:[@(count + 1) stringValue]];
                              [[nameFirebase childByAutoId] setValue:@{@"Name":[sender text]}];
                              
                              [self performSegueWithIdentifier:@"pushToMain" sender:self];
                          }
                          else
                          {
                              UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Name is used" message:@"Change another name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                              [alert show];
                          }
                      }
                  }];
             }
             else
             {
                 NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                 [defaults setValue:[sender text] forKey:@"Name"];
                 [defaults synchronize];
                 
                 [nameCountFirebase removeAllObservers];
                 [nameFirebase removeAllObservers];
                 [nameCountFirebase setValue:[@(count + 1) stringValue]];
                 [[nameFirebase childByAutoId] setValue:@{@"Name":[sender text]}];
                 
                 [self performSegueWithIdentifier:@"pushToMain" sender:self];
             }
         }];
    }
}

@end
