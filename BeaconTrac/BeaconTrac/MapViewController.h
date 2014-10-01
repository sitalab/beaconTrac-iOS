//
//  MapViewController.h
//  BeaconTrac
//
//  Created by Bilal Itani on 3/26/14.
//  Copyright (c) 2014 ITXi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *mapView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
-(void) setMapInControlView :(NSString *) Latitude :(NSString *) Longtitude;
-(void) setBeacons;

@end
