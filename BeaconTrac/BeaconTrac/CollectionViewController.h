//
//  CollectionViewController.h
//  BeaconTrac
//
//  Created by Bilal Itani on 3/26/14.
//  Copyright (c) 2014 ITXi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYMActivityIndicatorView.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CBCentralManager.h>

@interface CollectionViewController : UIViewController <CBCentralManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *beaconsTableView;
@property NSMutableArray *items, *ImmediateItems, *Nearitems, *Faritems, *UnknownItems, *NotInRangeItems;
@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) NSString *flag;
@property (retain, nonatomic) CLBeaconRegion *region;
@property (strong, nonatomic) IBOutlet UIView *rangingView;
@property (strong, nonatomic) IBOutlet UILabel *noBeaconsLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UILabel *rangingLabel;
@property (strong, nonatomic) IBOutlet UIImageView *infoIcon;
@property (assign) int regionGranularityOn;
@property (assign) int firstRangingFlag;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView1;
@property (nonatomic, strong) TYMActivityIndicatorView *activityIndicatorView2;
@property (nonatomic, strong) TYMActivityIndicatorView *activityIndicatorView3;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UISlider *slider;
-(void) updateBeaconList;
- (void) appIsLoadingBeacons;
- (void) noBeaconsLoaded;
- (void) showBeaconsFromAPI;
- (void) stopBeaconsRanging;
- (void) startRangingTimer;
- (void) startRanging;
- (void)closeMenu;
- (void) switchToRegionGranularity;

@end

