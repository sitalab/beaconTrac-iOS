//
//  MapViewController.m
//  BeaconTrac
//
//  Created by Bilal Itani on 3/26/14.
//  Copyright (c) 2014 ITXi. All rights reserved.
//

#import "MapViewController.h"
#import "MFSideMenu.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AppDelegate.h"
#import "PulsingHaloLayer.h"

@interface MapViewController ()
{
      GMSMapView *mapView_;
}
@end

@implementation MapViewController

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
    [_segmentedControl addTarget:self action:@selector(changeMapViewType:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeMapViewType:(id)sender {
    
    switch ([sender selectedSegmentIndex]) {
        case 0:
            mapView_.mapType = kGMSTypeNormal;
            break;
        case 1:
            mapView_.mapType = kGMSTypeHybrid;
            break;
        case 2:
            mapView_.mapType = kGMSTypeSatellite;
            break;
        case 3:
            mapView_.mapType = kGMSTypeTerrain;
            break;
        default:
            break;
    }
}

-(void) setMapInControlView :(NSString *) Latitude :(NSString *) Longtitude
{
    for (UIView *subview in [self.mapView subviews]) {
        
        [subview removeFromSuperview];
    }
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[Latitude floatValue]
                                                            longitude:[Longtitude floatValue]
                                                                 zoom:19];
    mapView_ = [GMSMapView mapWithFrame:self.mapView.bounds camera:camera];
    [self.mapView insertSubview:mapView_ atIndex:0];
    [self.mapView addSubview:_segmentedControl];
}

-(void) setBeacons
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items setArray:[[AppDelegate sharedAppDelegate] arrayOfBeaconsRanged]];
    [mapView_ clear];
    for(int i = 0; i < items.count; i++)
    {
        if( ![[items[i] objectForKey:@"name"] isEqualToString:@"Unregistered Beacon"] ){
            GMSMarker *marker = [[GMSMarker alloc] init];
            NSString *longitude = [items[i] objectForKey:@"longitude"] ;
            NSString *latitude = [items[i] objectForKey:@"latitude"] ;
            
            marker.position = CLLocationCoordinate2DMake([latitude floatValue],[longitude floatValue]);
            marker.title = [items[i] objectForKey:@"name"];
            marker.snippet = [items[i] objectForKey:@"beaconType"];
            if([[items[i] objectForKey:@"proximity"] isEqualToString:@"Far"] ||
               [[items[i] objectForKey:@"proximity"] isEqualToString:@"Near"] ||
               [[items[i] objectForKey:@"proximity"] isEqualToString:@"Immediate"])
                marker.icon = [UIImage imageNamed:@"BeaconMapIconInRange.png"];
            else
                marker.icon = [UIImage imageNamed:@"BeaconMapIcon.png"];
            marker.map = mapView_;
        }
    }
}
@end
