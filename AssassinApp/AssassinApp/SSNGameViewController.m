//
//  SSNGameViewController.m
//  AssassinApp
//
//  Created by Manav Mandhani on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "SSNGameViewController.h"
#import "Parse/Parse.h"

@interface SSNGameViewController ()
{
    NSDictionary *playerDict;
    NSDictionary *playerAttributes;
    NSString *timeRemaining;
    NSString *targetPlayer;
    NSString *lastKill;
    PFUser *loggedInUser;

    NSTimer *timer;
    int currMinute;
    int currSeconds;
}
@end


@implementation SSNGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query getObjectInBackgroundWithId:@"ZRlsokeDXs" block:^(PFObject *gameObject, NSError *error) {
        
        NSLog(@"%@", gameObject);
        lastKill = gameObject[@"last_kill"];
        playerDict = gameObject[@"player_dict"];
        
        loggedInUser = [PFUser currentUser];
        NSLog(@"%@", loggedInUser.username);
        playerAttributes =[playerDict valueForKeyPath:loggedInUser.username]; // Hard code to my username
        
//        NSLog(@"%@", _playerDict);
        targetPlayer = playerAttributes[@"target"];
        timeRemaining = playerAttributes[@"time_remaining"];
//        BOOL status = _playerAttributes[@"status"];
        
//        NSLog(@"%@ %@ %d", _targetPlayer, _timeRemaining, status);
        
        
        _targetLabel.hidden = false;
        _targetLabel.text = targetPlayer;
        
        _lastKillLabel.hidden = false;
        _lastKillLabel.text = lastKill;
        
        NSString *timeRemainingMessage = [NSString stringWithFormat:@"Time remaining to kill target: %@", timeRemaining];
        _timeRemainingLabel.hidden = false;
        _timeRemainingLabel.text = timeRemainingMessage;
        
        
        NSURL *url = [NSURL URLWithString:@"http://img4.wikia.nocookie.net/__cb20120524204707/gameofthrones/images/4/4d/Joffrey_in_armor2x09.jpg"];
        NSData *mydata = [[NSData alloc] initWithContentsOfURL:url];
        _targetImage.image = [UIImage imageWithData:mydata];
    }];
    NSLog(@"%@", playerDict);
}

- (IBAction)confirmKill:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query getObjectInBackgroundWithId:@"ZRlsokeDXs" block:^(PFObject *gameObject, NSError *error) {
        NSString *target = gameObject[@"player_dict"][loggedInUser.username][@"target"];
        NSString *newTarget = gameObject[@"player_dict"][target][@"target"];
        NSString *assassin = loggedInUser.username;
        NSString *killMessage = [NSString stringWithFormat:@"%@ killed %@", assassin, target];
        
        //updating target's stats
        gameObject[@"player_dict"][target][@"status"] = @NO;
        gameObject[@"player_dict"][target][@"time_remaining"] = @"0";
        gameObject[@"player_dict"][target][@"target"] = @"";
        
        //updating assasin's stats
        gameObject[@"player_dict"][[PFUser currentUser].username][@"target"] = newTarget;
        gameObject[@"player_dict"][[PFUser currentUser].username][@"time_remaining"] = @"260000";
        
        //updating game message
        gameObject[@"last_kill"] = killMessage;
        
        [gameObject saveInBackground];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)killConfirmButton:(id)sender {
}
@end
