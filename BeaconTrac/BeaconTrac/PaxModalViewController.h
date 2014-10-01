//
//  PaxModalViewController.h
//  BeaconTrac
//
//  Created by Bilal Itani on 4/28/14.
//  Copyright (c) 2014 ITXi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControlViewController.h"

@interface PaxModalViewController : UIViewController

@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItemCustom;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightSideBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *leftSideBtn;
@property (strong, nonatomic) IBOutlet UIView *RegisterView;
@property (strong, nonatomic) IBOutlet UIView *GranularityView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UITableViewCell *uuidRegion;
@property (strong, nonatomic) IBOutlet UITableViewCell *majorRegion;
@property (strong, nonatomic) IBOutlet UITableViewCell *minorRegion;
@property (strong, nonatomic) ControlViewController *Beacondelegate;
@property (strong, nonatomic) NSString *modalType;
@property (strong, nonatomic) IBOutlet UITextField *paxEmail;
@property (strong, nonatomic) IBOutlet UITextField *flightNumber;
@property (strong, nonatomic) IBOutlet UITableViewCell *airlineCell;
@property (strong, nonatomic) IBOutlet UILabel *airlineValue;
@property (strong, nonatomic) NSMutableDictionary *profileVals;
- (IBAction)DismissModal:(id)sender;
- (IBAction)SaveModal:(id)sender;

@end
