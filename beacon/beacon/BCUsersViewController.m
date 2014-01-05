//
//  BCFirstViewController.m
//  beacon
//
//  Created by Zac Bowling on 1/4/14.
//  Copyright (c) 2014 Hackathon. All rights reserved.
//

#import "BCUsersViewController.h"
#import "BCBeaconManager.h"
#import "BCWebViewController.h"
#import <Parse/Parse.h>

@interface BCUsersViewController ()

@end

@implementation BCUsersViewController

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserverForName:@"BCBeaconManagerUpdated" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self.tableView reloadData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[BCBeaconManager sharedManager] beacons] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *mainCell = [self.tableView dequeueReusableCellWithIdentifier:@"mainCell"];
    BCBeacon *beacon = [[[BCBeaconManager sharedManager] beacons] objectAtIndex:indexPath.row];
    mainCell.textLabel.text = beacon.title;
    if (beacon.type == BCBeaconTypeMarketing) {
        mainCell.backgroundColor = [UIColor colorWithRed:0.275 green:0.792 blue:0.369 alpha:1.0];
        mainCell.detailTextLabel.text = @"Special Offer";
        mainCell.imageView.image = [UIImage imageNamed:@"1007-price-tag"];
    } else {
        mainCell.backgroundColor = [UIColor whiteColor];
        mainCell.imageView.image = [UIImage imageNamed:@"973-user"];
        switch (beacon.proximity) {
            case CLProximityFar:
                mainCell.detailTextLabel.text = @"Distance: far";
                break;

            case CLProximityNear:
                mainCell.detailTextLabel.text = @"Distance: near";
                break;

            case CLProximityImmediate:
                mainCell.detailTextLabel.text = @"Distance: immediate";
                break;

            case CLProximityUnknown:
                mainCell.detailTextLabel.text = @"Distance: unkown";
                break;


            default:
                break;
        }
    }
    return mainCell;
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"openProfile"])
    {
        BCWebViewController *dest = (BCWebViewController *)segue.destinationViewController;
        BCBeacon *beacon = [[[BCBeaconManager sharedManager] beacons] objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        dest.initialPage = [NSURL URLWithString:beacon.profile[@"profilePage"]];
        dest.navigationItem.title = beacon.title;
    }

}


@end
