//
//  ControlViewController.h
//  BeaconTrac
//
//  Created by Bilal Itani on 3/26/14.
//  Copyright (c) 2014 ITXi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface ControlViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *mapview;
@property (strong, nonatomic) IBOutlet UIView *inRangeView;
@property (strong, nonatomic) IBOutlet UIView *inRegistryView;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScroll;
@property (strong, nonatomic) IBOutlet UITableView *locationsTableView;
@property (strong, nonatomic) IBOutlet UIImageView *SavedLegendView;
@property (strong, nonatomic) IBOutlet UIImageView *StaleLegendView;
@property (strong, nonatomic) IBOutlet UIImageView *NewLegendView;
@property (strong, nonatomic) IBOutlet UISwitch *notificationsSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *regionSwitch;
@property (assign) int regionGranularitySwitch;
@property (strong, nonatomic) IBOutlet UILabel *SavedLabel;
@property (strong, nonatomic) IBOutlet UILabel *StaleLabel;
@property (strong, nonatomic) IBOutlet UILabel *NewLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentLocationLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentLocationVal;
@property (strong, nonatomic) IBOutlet UILabel *otherLocationLabel;
@property (strong, nonatomic) IBOutlet UILabel *paxLabel;
@property (strong, nonatomic) IBOutlet UILabel *flightLabel;
@property (strong, nonatomic) IBOutlet UILabel *inRangeCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *inRegistryCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *appVersionLabel;
@property (strong, nonatomic) IBOutlet UILabel *monitoredCountLabel;
@property (strong, nonatomic) IBOutlet UIView *monitoredView;
@property (strong, nonatomic) IBOutlet UILabel *granularityLabel;
@property (strong, nonatomic) IBOutlet UITableViewCell *granularityCell;
- (IBAction)ModifyPAX:(id)sender;
- (IBAction)saveNotifications:(id)sender;
- (IBAction)SendLogs:(id)sender;
- (void)changeRegionGranularity;
- (void) shoModifyPAX;
-(void) setMapInControlView :(NSString *) Latitude :(NSString *) Longtitude :(NSString *) title :(NSString * ) snippet;

@end
