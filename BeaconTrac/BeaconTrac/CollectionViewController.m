 //
//  CollectionViewController.m
//  BeaconTrac
//
//  Created by Bilal Itani on 3/26/14.
//  Copyright (c) 2014 ITXi. All rights reserved.
//
#import "AppDelegate.h"
#import "CollectionViewController.h"
#import "MFSideMenu.h"
#import "AWCollectionViewDialLayout.h"
#import "PulsingHaloLayer.h"
#import "AppConstants.h"
#import "PaxModalViewController.h"
#import "Language.h"
#import <CoreLocation/CoreLocation.h>
#import "HTTPRequestCreator.h"
#import <CoreBluetooth/CBCentralManager.h>

@interface NSNull (JSON)
@end

@implementation NSNull (JSON)

- (NSUInteger)length { return 0; }
- (NSInteger)integerValue { return 0; };
- (CGFloat)floatValue { return 0; };
- (NSString *)description { return @""; }
- (BOOL)isEqualToString:(NSString *)compare { return FALSE; }
- (NSArray *)componentsSeparatedByString:(NSString *)separator { return @[]; }
- (id)objectForKey:(id)key { return nil; }
- (BOOL)boolValue { return NO; }

@end

@interface CollectionViewController () <CLLocationManagerDelegate>
    @property (nonatomic, strong) NSArray *beaconsArray;
@end

static NSString *cellId = @"cellId";
static NSString *cellId2 = @"cellId2";

@implementation CollectionViewController
{
    NSMutableDictionary *thumbnailCache;
    BOOL showingSettings;
    UIView *settingsView;
    UILabel *radiusLabel;
    UISlider *radiusSlider;
    UILabel *angularSpacingLabel;
    UISlider *angularSpacingSlider;
    UILabel *xOffsetLabel;
    UISlider *xOffsetSlider;
    UISegmentedControl *exampleSwitch;
    NSMutableDictionary *_beacons;
    CLLocationManager *_locationManager;
    NSMutableArray *_rangedRegions;
    NSString *_postedBeacons;
    NSTimer *rangingTimer;
    int type;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

@synthesize items, ImmediateItems, Nearitems, Faritems, UnknownItems, NotInRangeItems;

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state != CBCentralManagerStatePoweredOn && central.state != CBCentralManagerStateUnknown){
        NSString *stateString = nil;
        switch(central.state)
        {
            case CBCentralManagerStateResetting: stateString = @"Bluetooth connection with the system service was momentarily lost."; break;
            case CBCentralManagerStateUnsupported: stateString = @"The platform doesn't support Bluetooth Low Energy."; break;
            case CBCentralManagerStateUnauthorized: stateString = @"The app is not authorized to use Bluetooth Low Energy."; break;
            case CBCentralManagerStatePoweredOff: stateString = @"Bluetooth is currently powered off."; break;
            default: stateString = @"Bluetooth state unknown..."; break;
        }
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Bluetooth problem!"
                              message: stateString
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)menuStateEventOccurred:(NSNotification *)notification {
    MFSideMenuStateEvent event = [[[notification userInfo] objectForKey:@"eventType"] intValue];
    if(event == MFSideMenuStateEventMenuDidClose ){
        if([((ControlViewController *)self.navigationController.menuContainerViewController.leftMenuViewController).flightLabel.text isEqualToString:@""]){
            
            [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
                [self setupMenuBarButtonItems];
            }];
            
            [((ControlViewController *)self.navigationController.menuContainerViewController.leftMenuViewController) shoModifyPAX];
        }
    }
}

- (void)closeMenu {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    
    if(CLLocationManager.authorizationStatus != kCLAuthorizationStatusAuthorized){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Allow Location Access"
                              message: @"Please allow BeaconTrac Location access."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }else if(![CLLocationManager locationServicesEnabled]){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Enable Location Services"
                              message: @"Please enable loaction services on device for BeaconTrac."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }else if(![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Beacons are not supported"
                              message: @"Your device does not support Beacons, applpciation will not work properly."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }else if(![CLLocationManager isRangingAvailable]){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Beacons are not supported"
                              message: @"Your device does not support Beacons, applpciation will not work properly."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(menuStateEventOccurred:)
        name:MFSideMenuStateNotificationEvent
        object:nil];
    
    ImmediateItems =  [[NSMutableArray alloc] init];
    Nearitems =  [[NSMutableArray alloc] init];
    Faritems =  [[NSMutableArray alloc] init];
    NotInRangeItems =  [[NSMutableArray alloc] init];
    UnknownItems = [[NSMutableArray alloc] init];
    
    _locationManager = [[CLLocationManager alloc] init];
    _region = nil;
    _postedBeacons = @"";
    _regionGranularityOn = 0;
    
    for (CLBeaconRegion *monitoredRegion in [_locationManager monitoredRegions]){
        NSLog(@"monitoredRegion: %@", monitoredRegion);
        [_locationManager stopMonitoringForRegion:monitoredRegion];
    }
    _locationManager.delegate = self;
    
    _activityIndicatorView3 = [[TYMActivityIndicatorView alloc] initWithActivityIndicatorStyle:TYMActivityIndicatorViewStyleLarge];
    _activityIndicatorView3.hidesWhenStopped = NO;
    _activityIndicatorView3.frame = CGRectMake(82, 234, 157, 157);
    [_activityIndicatorView3 setBackgroundImage:[UIImage imageNamed:@"Activity-Icon.png"]];
    
    _infoLabel.text = [Language getLocalizedStringByKey:@"Tap on beacon to configure"];
    [self setupMenuBarButtonItems];
    self.flag = @"Yes";
    
    [_beaconsTableView setFrame:CGRectMake(0, 90, 320, [[UIScreen mainScreen] bounds].size.height-90)];
    [_beaconsTableView setFrame:CGRectMake(0, 26, 320, [[UIScreen mainScreen] bounds].size.height-26)];
    [_beaconsTableView registerNib:[UINib nibWithNibName:@"BeaconCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellId];

    items = [[AppDelegate sharedAppDelegate] arrayOfBeacons];
    CGFloat radius = radiusSlider.value * 1000;
    CGFloat angularSpacing = angularSpacingSlider.value * 90;
    CGFloat xOffset = xOffsetSlider.value * 320;
    CGFloat cell_width = 275;
    CGFloat cell_height = 83;
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
         radius = radiusSlider.value * 1000;
         angularSpacing = angularSpacingSlider.value * 90;
         xOffset = xOffsetSlider.value * 320;
         cell_width = 480;
         cell_height = 200;
    }
    
    _beaconsTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_beaconsTableView];
    [self appIsLoadingBeacons];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 40 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self noBeaconsLoaded];
    });
    
    [self.view bringSubviewToFront:_infoLabel];
    [self.view bringSubviewToFront:_infoIcon];
    [self.view bringSubviewToFront:_noBeaconsLabel];
    [self.view bringSubviewToFront:_rangingLabel];
    [self.view bringSubviewToFront:_rangingButton];
    [self.view bringSubviewToFront:_rangingView];
    
    _firstRangingFlag = 0;
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _rangingLabel.hidden = TRUE;
}

- (void) switchToRegionGranularity{
    
    for (CLBeaconRegion *monitoredRegion in [_locationManager monitoredRegions]){
        NSLog(@"Removing monitoredRegion: %@", monitoredRegion);
        [_locationManager stopMonitoringForRegion:monitoredRegion];
    }
    
    if( _regionGranularityOn == REGION_UUID_MAJORID_MINORID ){
        if([[AppDelegate sharedAppDelegate] arrayOfBeacons].count > 0){
            for (int i = 0; i < [[AppDelegate sharedAppDelegate] arrayOfBeacons].count; i++) {
                NSDictionary *item = [[[AppDelegate sharedAppDelegate] arrayOfBeacons] objectAtIndex:i];
                CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:[item objectForKey:@"uuid"]] major:[[item objectForKey:@"majorId"] integerValue] minor:[[item objectForKey:@"minorId"] integerValue] identifier:[NSString stringWithFormat:@"BeaconTReg%d", i]];
                
                region.notifyOnEntry = TRUE;
                region.notifyOnExit = TRUE;
                region.notifyEntryStateOnDisplay = YES;
                [_locationManager startMonitoringForRegion:region];
                
                NSString *regionsBeingMonitoredKey = @"";
                regionsBeingMonitoredKey = [NSString stringWithFormat:@"%@/%@/%@",[region.proximityUUID UUIDString], region.major, region.minor ];
                NSMutableDictionary *regionBeingMonitoredDict =[[NSMutableDictionary alloc]init];
                [regionBeingMonitoredDict setValue:region.proximityUUID.UUIDString forKey:@"uuid"];
                [regionBeingMonitoredDict setValue:region.major forKey:@"major"];
                [regionBeingMonitoredDict setValue:region.minor forKey:@"minor"];
                [regionBeingMonitoredDict setValue:region.identifier forKey:@"identifier"];
                [regionBeingMonitoredDict setObject:@"" forKey:@"state"];
                [[AppDelegate sharedAppDelegate].regionsBeingMonitored setObject:  regionBeingMonitoredDict forKey: regionsBeingMonitoredKey];

            }
        }
    }else if(_regionGranularityOn == REGION_UUID){
        if([AppDelegate sharedAppDelegate].arrayOfUniqueUUIDs.count > 0){
            for (int i = 0; i < [AppDelegate sharedAppDelegate].arrayOfUniqueUUIDs.count; i++) {
                CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:[AppDelegate sharedAppDelegate].arrayOfUniqueUUIDs[i]] identifier:[NSString stringWithFormat:@"BeaconTReg%d", i]];
                region.notifyOnEntry = TRUE;
                region.notifyOnExit = TRUE;
                region.notifyEntryStateOnDisplay = YES;
                [_locationManager startMonitoringForRegion:region];
                
                NSString *regionsBeingMonitoredKey = @"";
                regionsBeingMonitoredKey = [NSString stringWithFormat:@"%@",[region.proximityUUID UUIDString]];
                NSMutableDictionary *regionBeingMonitoredDict =[[NSMutableDictionary alloc]init];
                [regionBeingMonitoredDict setValue:region.proximityUUID.UUIDString forKey:@"uuid"];
                [regionBeingMonitoredDict setValue:region.major forKey:@"major"];
                [regionBeingMonitoredDict setValue:region.minor forKey:@"minor"];
                [regionBeingMonitoredDict setValue:region.identifier forKey:@"identifier"];
                [regionBeingMonitoredDict setObject:@"" forKey:@"state"];
                [[AppDelegate sharedAppDelegate].regionsBeingMonitored setObject:  regionBeingMonitoredDict forKey: regionsBeingMonitoredKey];

            }
        }
    
    }else{
        if([AppDelegate sharedAppDelegate].arrayOfUniqueMajorIDs.count > 0){
            for (int i = 0; i < [AppDelegate sharedAppDelegate].arrayOfUniqueMajorIDs.count; i++) {
                
                NSArray* UUIDMajorArr = [[AppDelegate sharedAppDelegate].arrayOfUniqueMajorIDs[i] componentsSeparatedByString: @" "];
                
                CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:UUIDMajorArr[0]] major: [UUIDMajorArr[1] integerValue] identifier:[NSString stringWithFormat:@"BeaconTReg%d", i]];
                region.notifyOnEntry = TRUE;
                region.notifyOnExit = TRUE;
                region.notifyEntryStateOnDisplay = YES;
                [_locationManager startMonitoringForRegion:region];
                
                NSString *regionsBeingMonitoredKey = @"";
                regionsBeingMonitoredKey = [NSString stringWithFormat:@"%@/%@",[region.proximityUUID UUIDString], region.major ];
                NSMutableDictionary *regionBeingMonitoredDict =[[NSMutableDictionary alloc]init];
                [regionBeingMonitoredDict setValue:region.proximityUUID.UUIDString forKey:@"uuid"];
                [regionBeingMonitoredDict setValue:region.major forKey:@"major"];
                [regionBeingMonitoredDict setValue:region.minor forKey:@"minor"];
                [regionBeingMonitoredDict setValue:region.identifier forKey:@"identifier"];
                [regionBeingMonitoredDict setObject:@"" forKey:@"state"];
                [[AppDelegate sharedAppDelegate].regionsBeingMonitored setObject:  regionBeingMonitoredDict forKey: regionsBeingMonitoredKey];

            }
        }
    }
}

- (void) appIsLoadingBeacons{
    _beaconsTableView.hidden =  TRUE;
    _noBeaconsLabel.hidden = TRUE;
    _infoLabel.hidden = TRUE;
    _infoIcon.hidden = TRUE;
    
    [self.view addSubview:_activityIndicatorView3];
    [self.activityIndicatorView3 startAnimating];
}

- (void) noBeaconsLoaded{
    if( [items count] < 1 ){
        _beaconsTableView.hidden =  TRUE;
        _noBeaconsLabel.text = [Language getLocalizedStringByKey:@"No beacons for me to manage :("];
        _noBeaconsLabel.hidden = FALSE;
        _infoLabel.hidden = TRUE;
        _infoIcon.hidden = TRUE;
    }
    
    [self.activityIndicatorView3 stopAnimating];
    [self.activityIndicatorView3 removeFromSuperview];
}

- (void) clearForBlueToothRanging{
    _rangingLabel.hidden = FALSE;
    _beaconsTableView.hidden =  FALSE;
    _noBeaconsLabel.hidden = TRUE;
    _infoLabel.hidden = FALSE;
    _infoIcon.hidden = FALSE;
    
    [self.activityIndicatorView3 stopAnimating];
    [self.activityIndicatorView3 removeFromSuperview];
}

- (void) showRangingLabel {
    _rangingLabel.text = @"Ranging Beacons...";
}

- (void) hideRangingLabel {
    _rangingLabel.text = @"Not Ranging...";
}

- (void)startRangingTimer{
    if(rangingTimer != nil){
        [rangingTimer invalidate];
        rangingTimer = nil;
    }
    
    rangingTimer =  [NSTimer scheduledTimerWithTimeInterval:RanginInterval target:self selector:@selector(startRanging) userInfo:nil repeats:YES];
}

- (void)startRanging{
    if(_region != nil){
        [self showRangingLabel];
        _firstRangingFlag = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_locationManager startRangingBeaconsInRegion:_region];
        });
    }
}

- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [_locationManager requestStateForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        
        if (state == CLRegionStateInside)
            NSLog(@"didDetermineState UUID:%@ Major:%@ MinorD:%@ CLRegionStateInside", beaconRegion.proximityUUID.UUIDString , beaconRegion.major, beaconRegion.minor);
        else if (state == CLRegionStateOutside)
            NSLog(@"didDetermineState UUID:%@ Major:%@ MinorD:%@ CLRegionStateOutside", beaconRegion.proximityUUID.UUIDString , beaconRegion.major, beaconRegion.minor);
        else if (state == CLRegionStateUnknown)
            NSLog(@"didDetermineState UUID:%@ Major:%@ MinorD:%@ CLRegionStateUnknown", beaconRegion.proximityUUID.UUIDString , beaconRegion.major, beaconRegion.minor);
        
        /**
         * Get the NSDictionary entry holding the info for this region being monitored.
         */
        NSString *regionsBeingMonitoredKey = @"";
        if (beaconRegion.minor != NULL)
            regionsBeingMonitoredKey = [NSString stringWithFormat:@"%@/%@/%@",[beaconRegion.proximityUUID UUIDString], beaconRegion.major, beaconRegion.minor ];
        else if (beaconRegion.major != NULL)
            regionsBeingMonitoredKey = [NSString stringWithFormat:@"%@/%@",[beaconRegion.proximityUUID UUIDString], beaconRegion.major ];
        else
            regionsBeingMonitoredKey = [NSString stringWithFormat:@"%@",[beaconRegion.proximityUUID UUIDString]];
        NSMutableDictionary *regionsBeingMonitored = [AppDelegate sharedAppDelegate].regionsBeingMonitored;
        NSMutableDictionary *regionInfo = [regionsBeingMonitored objectForKey:regionsBeingMonitoredKey];
        if (state == CLRegionStateInside) {
            [regionInfo setObject:@"CLRegionStateInside" forKey:@"state"];
        }
        else if (state == CLRegionStateOutside) {
            [regionInfo setObject:@"CLRegionStateOutside" forKey:@"state"];
        }
        else if (state == CLRegionStateUnknown) {
            [regionInfo setObject:@"CLRegionStateUnknown" forKey:@"state"];
        }

        
        
        for (CLBeaconRegion *monitoredRegion in [_locationManager rangedRegions])
            [_locationManager stopRangingBeaconsInRegion:monitoredRegion];
        
        if (state == CLRegionStateInside) {
            // Start Ranging - always range for all beacons matching the Airport UUID.
//            _region = beaconRegion;
//            _region.self.major.self = NULL;
            
            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beaconRegion.proximityUUID.UUIDString];
            _region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"aero.sita.lab.airportuuid"];

        
            [self showRangingLabel];
            
            if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
                [_locationManager startRangingBeaconsInRegion:_region];
            else
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [_locationManager startRangingBeaconsInRegion:_region];
                });
                
            [self startRangingTimer];
        }
        
        [[AppDelegate sharedAppDelegate].leftViewController.locationsTableView reloadData];
    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError: %@", [error description]);
}

- (void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    
    NSLog(@"%@", [error description]);
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        NSLog(@"monitoringDidFailForRegion: UUID:%@ Major:%@ MinorD:%@", beaconRegion.proximityUUID.UUIDString , beaconRegion.major, beaconRegion.minor);
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        NSLog(@"didEnterRegion UUID:%@ Major:%@ MinorD:%@", beaconRegion.proximityUUID.UUIDString , beaconRegion.major, beaconRegion.minor);
        
        for (CLBeaconRegion *currRangedRegions in [_locationManager rangedRegions])
            [_locationManager stopRangingBeaconsInRegion:currRangedRegions];
        _firstRangingFlag = 0;
        _region = beaconRegion;
        [self showRangingLabel];
        
        if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
            [_locationManager startRangingBeaconsInRegion:_region];
        else
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [_locationManager startRangingBeaconsInRegion:_region];
            });

        [self startRangingTimer];
        
        if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
            [self didEnterRegionActions:beaconRegion];
        else
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 7 * NSEC_PER_SEC), dispatch_get_main_queue(),
            ^{
                NSLog(@"didEnterRegionActions delayed");
                [self didEnterRegionActions:beaconRegion];
            });
    }
}

- (void) didEnterRegionActions:(CLBeaconRegion *)beaconRegion
{
    NSLog(@"didEnterRegionActions entered");
    NSString *logsRegionName = @"";
    
    if (beaconRegion.minor != NULL)
        logsRegionName = [NSString stringWithFormat:@"%@/%@/%@",[beaconRegion.proximityUUID UUIDString], beaconRegion.major, beaconRegion.minor ];
    else if (beaconRegion.major != NULL)
        logsRegionName = [NSString stringWithFormat:@"%@/%@",[beaconRegion.proximityUUID UUIDString], beaconRegion.major ];
    else
        logsRegionName = [NSString stringWithFormat:@"%@",[beaconRegion.proximityUUID UUIDString]];

    
  /*
    if([AppDelegate sharedAppDelegate].regionGranularity == REGION_UUID){
        logsRegionName = [[AppDelegate sharedAppDelegate].arrayOfUniqueUUIDs valueForKey:[beaconRegion.proximityUUID UUIDString]];
    }else if([AppDelegate sharedAppDelegate].regionGranularity == REGION_UUID_MAJORID_MINORID){
        if( [AppDelegate sharedAppDelegate].arrayOfBeacons.count > 0 ){
            for(int i = 0; i < [AppDelegate sharedAppDelegate].arrayOfBeacons.count; i++)
            {
                NSString *currRegName = [NSString stringWithFormat:@"%@%@%@",[beaconRegion.proximityUUID UUIDString], beaconRegion.major, beaconRegion.minor ];
                
                NSString *regRegName = [NSString stringWithFormat:@"%@%@%@",[[AppDelegate sharedAppDelegate].arrayOfBeacons[i] objectForKey:@"uuid"], [[AppDelegate sharedAppDelegate].arrayOfBeacons[i] objectForKey:@"majorId"], [[AppDelegate sharedAppDelegate].arrayOfBeacons[i] objectForKey:@"minorId"] ];
                
                if( [currRegName isEqualToString:regRegName] ){
                    logsRegionName =[[AppDelegate sharedAppDelegate].arrayOfBeacons[i] objectForKey:@"name"];
                }
            }
        }
    }else{
        if( ![MAjorsDictionary objectForKey:[beaconRegion.major stringValue]] )
            logsRegionName = [NSString stringWithFormat:@"You have entered an unknown zone (%@)", beaconRegion.major];
        else
            logsRegionName = [NSString stringWithFormat:@"You have entered a %@ zone (%@)", [MAjorsDictionary objectForKey:[beaconRegion.major stringValue]], beaconRegion.major];
    }*/
    
    [AppDelegate addLog: logsRegionName];
    
    if(((ControlViewController *)self.navigationController.menuContainerViewController.leftMenuViewController).regionSwitch.isOn){
        
        if([AppDelegate sharedAppDelegate].regionGranularity == REGION_UUID){
            UILocalNotification *notification = [UILocalNotification new];
            
            //NSMutableDictionary *regionsBeingMonitored = [AppDelegate sharedAppDelegate].regionsBeingMonitored;
            //NSMutableDictionary *regionInfo = [regionsBeingMonitored objectForKey:beaconRegion.identifier];
            
            notification.alertBody = [NSString stringWithFormat:@"Entered %@ region", logsRegionName];//[regionInfo objectForKey:@"regionName"]];
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }else if([AppDelegate sharedAppDelegate].regionGranularity == REGION_UUID_MAJORID_MINORID){
            NSString *regionName = @"";
            if( [AppDelegate sharedAppDelegate].arrayOfBeacons.count > 0 ){
                for(int i = 0; i < [AppDelegate sharedAppDelegate].arrayOfBeacons.count; i++)
                {
                    NSLog(@"curr region :%@", [AppDelegate sharedAppDelegate].arrayOfBeacons[i]);
                    NSString *currRegName = [NSString stringWithFormat:@"%@%@%@",[beaconRegion.proximityUUID UUIDString], beaconRegion.major, beaconRegion.minor ];
                    
                    NSString *regRegName = [NSString stringWithFormat:@"%@%@%@",[[AppDelegate sharedAppDelegate].arrayOfBeacons[i] objectForKey:@"uuid"], [[AppDelegate sharedAppDelegate].arrayOfBeacons[i] objectForKey:@"majorId"], [[AppDelegate sharedAppDelegate].arrayOfBeacons[i] objectForKey:@"minorId"] ];
                    
                    if( [currRegName isEqualToString:regRegName] ){
                        regionName = [NSString stringWithFormat:@"Entered %@", [[AppDelegate sharedAppDelegate].arrayOfBeacons[i] objectForKey:@"name"]];
                    }
                }
                UILocalNotification *notification = [UILocalNotification new];
                notification.alertBody = regionName;
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            }
        }else{
            NSString *regionName = @"";
            if( ![MAjorsDictionary objectForKey:[beaconRegion.major stringValue]] )
                regionName = [NSString stringWithFormat:@"You have entered an unknown zone (%@)", beaconRegion.major];
            else
                regionName = [NSString stringWithFormat:@"You have entered a %@ zone (%@)", [MAjorsDictionary objectForKey:[beaconRegion.major stringValue]], beaconRegion.major];
            
            UILocalNotification *notification = [UILocalNotification new];
            notification.alertBody = regionName;
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }
    }
        NSLog(@"didEnterRegionActions entered 2");
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        NSLog(@"didExitRegion UUID:%@ Major:%@ MinorD:%@", beaconRegion.proximityUUID.UUIDString , beaconRegion.major, beaconRegion.minor);

        if(rangingTimer != nil){
            [rangingTimer invalidate];
            rangingTimer = nil;
        }
        
        if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
            [self didExitRegionActions:beaconRegion];

        else
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 7 * NSEC_PER_SEC), dispatch_get_main_queue(),
            ^{
                [self didExitRegionActions:beaconRegion];
                NSLog(@"didExitRegionActions delayed");
            });
    }
}

- (void) didExitRegionActions:(CLBeaconRegion *)beaconRegion
{
    NSLog(@"didExitRegionActions entered");
    [[AppDelegate sharedAppDelegate] postBeaconsLogToServer];
    NSString *logsRegionName = @"";
    
    if (beaconRegion.minor != NULL)
        logsRegionName = [NSString stringWithFormat:@"%@/%@/%@",[beaconRegion.proximityUUID UUIDString], beaconRegion.major, beaconRegion.minor ];
    else if (beaconRegion.major != NULL)
        logsRegionName = [NSString stringWithFormat:@"%@/%@",[beaconRegion.proximityUUID UUIDString], beaconRegion.major ];
    else
        logsRegionName = [NSString stringWithFormat:@"%@",[beaconRegion.proximityUUID UUIDString]];

    [AppDelegate addLog:logsRegionName];
    
    if(((ControlViewController *)self.navigationController.menuContainerViewController.leftMenuViewController).regionSwitch.isOn){
        
        if([AppDelegate sharedAppDelegate].regionGranularity == REGION_UUID){
            UILocalNotification *notification = [UILocalNotification new];
            notification.alertBody = [NSString stringWithFormat:@"Exited %@ region", logsRegionName];
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }else if([AppDelegate sharedAppDelegate].regionGranularity == REGION_UUID_MAJORID_MINORID){
            NSString *regionName = @"";
            if( [AppDelegate sharedAppDelegate].arrayOfBeacons.count > 0 ){
                for(int i = 0; i < [AppDelegate sharedAppDelegate].arrayOfBeacons.count; i++)
                {
                    NSLog(@"curr region :%@", [AppDelegate sharedAppDelegate].arrayOfBeacons[i]);
                    
                    NSString *currRegName = [NSString stringWithFormat:@"%@%@%@",[beaconRegion.proximityUUID UUIDString], beaconRegion.major, beaconRegion.minor ];
                    
                    NSString *regRegName = [NSString stringWithFormat:@"%@%@%@",[[AppDelegate sharedAppDelegate].arrayOfBeacons[i] objectForKey:@"uuid"], [[AppDelegate sharedAppDelegate].arrayOfBeacons[i] objectForKey:@"majorId"], [[AppDelegate sharedAppDelegate].arrayOfBeacons[i] objectForKey:@"minorId"] ];
                    
                    if( [currRegName isEqualToString:regRegName] ){
                        regionName = [NSString stringWithFormat:@"Exited %@", [[AppDelegate sharedAppDelegate].arrayOfBeacons[i] objectForKey:@"name"]];
                    }
                }
                UILocalNotification *notification = [UILocalNotification new];
                notification.alertBody = regionName;
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            
            }
        }else{
            NSString *regionName = @"";
            if( ![MAjorsDictionary objectForKey:[beaconRegion.major stringValue]] )
                regionName = [NSString stringWithFormat:@"You have exited an unknown zone (%@)", beaconRegion.major];
            else
                regionName = [NSString stringWithFormat:@"You have exited %@ zone (%@)", [MAjorsDictionary objectForKey:[beaconRegion.major stringValue]], beaconRegion.major];
            UILocalNotification *notification = [UILocalNotification new];
            notification.alertBody = regionName;
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }
    }
    NSLog(@"didExitRegionActions entered 2");
}

- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if(_firstRangingFlag == 0){
        [[AppDelegate sharedAppDelegate] addBeaconsLog:beacons];
        [self clearForBlueToothRanging];
        self.beaconsArray = beacons;
        NSMutableArray *updatedBeaconsArray = [[NSMutableArray alloc] init];

        for(id currBeacon in beacons){
            CLBeacon *beacon = currBeacon;
            
            NSLog(@"%@", [NSString stringWithFormat:@"Major: %@, Minor: %@", beacon.major, beacon.minor]);
            NSLog(@"%@", [NSString stringWithFormat:@"Distance: %ld", (long)beacon.rssi]);
            NSLog(@"%@", beacon.description);
            
            NSMutableDictionary *tempBeacon = [[NSMutableDictionary alloc] init];
            [tempBeacon setObject:@"+" forKey:@"Action"];
            [tempBeacon setObject:@"Unregistered Beacon" forKey:@"name"];
            [tempBeacon setObject:[beacon.proximityUUID UUIDString] forKey:@"uuid"];
            [tempBeacon setObject:beacon.major forKey:@"majorId"];
            [tempBeacon setObject:beacon.minor forKey:@"minorId"];
            NSString *rssi = [NSString stringWithFormat:@"%ld", (long)beacon.rssi];
            [tempBeacon setObject:rssi forKey:@"rssi"];
            [tempBeacon setObject:@"N/A" forKey:@"beaconType"];
            [tempBeacon setObject:@"0" forKey:@"latitude"];
            [tempBeacon setObject:@"0" forKey:@"longitude"];
            [tempBeacon setObject:@"N/A" forKey:@"floor"];
            [tempBeacon setObject:@"false" forKey:@"airside"];
            [tempBeacon setObject:@"false" forKey:@"publicBeacon"];
            
            if( [[self textForProximity:beacon.proximity] isEqualToString:@"Far"] )
                [tempBeacon setObject:New_BeaconColor forKey:@"team-color"];
            else if( [[self textForProximity:beacon.proximity] isEqualToString:@"Near"] )
                [tempBeacon setObject:New_BeaconColor forKey:@"team-color"];
            else if( [[self textForProximity:beacon.proximity] isEqualToString:@"Immediate"] )
                [tempBeacon setObject:New_BeaconColor forKey:@"team-color"];
            else
                [tempBeacon setObject:New_BeaconColor forKey:@"team-color"];
            
            [tempBeacon setObject:@"" forKey:@"picture"];
            [tempBeacon setObject:[self textForProximity:beacon.proximity] forKey:@"proximity"];
            [updatedBeaconsArray insertObject:tempBeacon atIndex:updatedBeaconsArray.count];
        }

        for(id currBeaconFromAPI in [[AppDelegate sharedAppDelegate] arrayOfBeacons]){
            NSDictionary *item = currBeaconFromAPI;
            NSMutableDictionary *tempBeacon = [[NSMutableDictionary alloc] init];
            [tempBeacon setObject:@"-" forKey:@"Action"];
            [tempBeacon setObject:[item valueForKey:@"name"] forKey:@"name"];
            [tempBeacon setObject:[item valueForKey:@"location"] forKey:@"location"];
            [tempBeacon setObject:[item objectForKey:@"uuid"] forKey:@"uuid"];
            [tempBeacon setObject:[item objectForKey:@"majorId"] forKey:@"majorId"];
            [tempBeacon setObject:[item objectForKey:@"minorId"] forKey:@"minorId"];
            [tempBeacon setObject:[item objectForKey:@"beaconType"] forKey:@"beaconType"];
            [tempBeacon setObject:NotInRange_BeaconColor forKey:@"team-color"];
            [tempBeacon setObject:@"" forKey:@"picture"];
            [tempBeacon setObject:@"N/A" forKey:@"rssi"];
            [tempBeacon setObject:@"N/A" forKey:@"proximity"];
            [tempBeacon setObject:[item objectForKey:@"latitude"] forKey:@"latitude"];
            [tempBeacon setObject:[item objectForKey:@"longitude"] forKey:@"longitude"];
            [tempBeacon setObject:[item objectForKey:@"beaconType"] forKey:@"beaconType"];
            [tempBeacon setObject:[item objectForKey:@"airside"] forKey:@"airside"];
            [tempBeacon setObject:[item objectForKey:@"publicBeacon"] forKey:@"publicBeacon"];
            [tempBeacon setObject:[item objectForKey:@"idBeacon"] forKey:@"idBeacon"];
            [tempBeacon setObject:[item objectForKey:@"floor"] forKey:@"floor"];
            [tempBeacon setObject:[item objectForKey:@"advertisingInterval"] forKey:@"advertisingInterval"];
            [tempBeacon setObject:[item objectForKey:@"hardwareVersion"] forKey:@"hardwareVersion"];
            
            if( [item objectForKey:@"brandName"] )
                [tempBeacon setObject:[item objectForKey:@"brandName"] forKey:@"brandName"];
            
            [tempBeacon setObject:[[item objectForKey:@"organisation"] objectForKey:@"idOrganisation"] forKey:@"idOrganisation"];
            [tempBeacon setObject:[[item objectForKey:@"organisation"] objectForKey:@"name"] forKey:@"orgName"];
            [tempBeacon setObject:[[item objectForKey:@"organisation"] objectForKey:@"systemName"] forKey:@"systemName"];
            [tempBeacon setObject:[item objectForKey:@"dateAdded"] forKey:@"dateAdded"];
            [tempBeacon setObject:[item objectForKey:@"lastUpdate"] forKey:@"lastUpdate"];
            [tempBeacon setObject:[item objectForKey:@"macAddress"] forKey:@"macAddress"];
            if([item objectForKey:@"metaData"])
                [tempBeacon setObject:[item objectForKey:@"metaData"] forKey:@"metaData"];
            [tempBeacon setObject:[item objectForKey:@"power"] forKey:@"power"];
            [tempBeacon setObject:[item objectForKey:@"softwareVersion"] forKey:@"softwareVersion"];
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
            NSDate *formattedDate = [dateFormatter dateFromString:[item objectForKey:@"lastUpdate"]];
            
            
            NSLog(@"%ld", (long)[self daysBetweenDates:formattedDate andDate:[NSDate date]]);
            
            if( (long)[self daysBetweenDates:formattedDate andDate:[NSDate date]] > 6 )
                [tempBeacon setObject:NotInRange_BeaconColor forKey:@"team-color"];
            
            [updatedBeaconsArray insertObject:tempBeacon atIndex:updatedBeaconsArray.count];
        }

        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for(int i = 0; i < updatedBeaconsArray.count; i++)
        {
            int exist = 0;
            NSString *key = [NSString stringWithFormat:@"%@%@%@",[updatedBeaconsArray[i] objectForKey:@"uuid"],[updatedBeaconsArray[i] objectForKey:@"majorId"],[updatedBeaconsArray[i] objectForKey:@"minorId"]];
            
            for(int j = 0; j < tempArray.count; j++)
            {
                NSString *secondKey=[NSString stringWithFormat:@"%@%@%@",[tempArray[j] objectForKey:@"uuid"],[tempArray[j] objectForKey:@"majorId"],[tempArray[j] objectForKey:@"minorId"]];
                if([key isEqualToString:secondKey])
                {
                    exist++;
                    if([[tempArray[j] objectForKey:@"proximity"] isEqualToString:@"N/A"])
                    {
                        NSMutableDictionary *tempBeacon = [[NSMutableDictionary alloc] init];
                        [tempBeacon setDictionary:tempArray[j]];
                        [tempBeacon setValue:[updatedBeaconsArray[i] objectForKey:@"proximity"] forKey:@"proximity"];
                        [tempBeacon setValue:[updatedBeaconsArray[i] objectForKey:@"rssi"] forKey:@"rssi"];
                        [tempBeacon setValue:API_BeaconColor forKey:@"team-color"];
                        
                        [tempArray replaceObjectAtIndex:j withObject:tempBeacon];
                    }
                    else if([[updatedBeaconsArray[i] objectForKey:@"proximity"] isEqualToString:@"N/A"])
                    {
                        NSMutableDictionary *tempBeacon = [[NSMutableDictionary alloc] init];
                        [tempBeacon setDictionary:updatedBeaconsArray[i]];
                        [tempBeacon setValue:[tempArray[j] objectForKey:@"proximity"] forKey:@"proximity"];
                        [tempBeacon setValue:[tempArray[j] objectForKey:@"rssi"] forKey:@"rssi"];
                        [tempBeacon setValue:API_BeaconColor forKey:@"team-color"];
                        [tempArray replaceObjectAtIndex:j withObject:tempBeacon];
                    }
                }
            }
            
            if(exist == 0)
                [tempArray insertObject:updatedBeaconsArray[i] atIndex:tempArray.count];
        }

        NSMutableArray *ApiBeacons = [[NSMutableArray alloc] init];
        for(int i = 0; i < tempArray.count; i++)
        {
            if([[tempArray[i] objectForKey:@"name"] isEqualToString:@"Unregistered Beacon"])
                ;
            else
                [ApiBeacons insertObject:tempArray[i] atIndex:ApiBeacons.count];
        }

        for(int i = 0; i < tempArray.count; i++)
        {
            if(![[tempArray[i] objectForKey:@"name"] isEqualToString:@"Unregistered Beacon"] && ![[tempArray[i] objectForKey:@"proximity"] isEqualToString:@"N/A"]){
                
                NSString *tempUniqueSTR = [NSString stringWithFormat:@"%@-%@-%@",[tempArray[i] objectForKey:@"uuid"], [tempArray[i] objectForKey:@"majorId"], [tempArray[i] objectForKey:@"minorId"] ];
                
                if(![_postedBeacons isEqualToString:tempUniqueSTR]){
                    _postedBeacons = tempUniqueSTR;
                
                NSString *flight = [((ControlViewController *)self.navigationController.menuContainerViewController.leftMenuViewController).flightLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSString *pax = ((ControlViewController *)self.navigationController.menuContainerViewController.leftMenuViewController).paxLabel.text;
                    
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];

                NSString *BeaconKeyPOST = @"";
                NSString *BeaconAppIdPOST = @"";
                if( [[AppDelegate sharedAppDelegate].mainAirport isEqualToString:@"SIN"] ){
                    BeaconKeyPOST = SIN_BeaconAPIKey;
                    BeaconAppIdPOST = SIN_appId;
                }
                else{
                    BeaconKeyPOST = BeaconAPIKey;
                    BeaconAppIdPOST = appId;
                }
                    
                NSString *postBeaconFoundToAPI = [NSString stringWithFormat:@"%@/%@/%@/%@/%@?ignoreMe&flightNumber=%@&flightDate=%@&passengerIdentifier=%@&measuredRSSI=%@&deviceIdentifier=%@&app_id=%@&app_key=%@",
                beaconsUrl,
                [AppDelegate sharedAppDelegate].mainAirport,
                [tempArray[i] objectForKey:@"uuid"],
                [tempArray[i] objectForKey:@"majorId"],
                [tempArray[i] objectForKey:@"minorId"],
                flight,
                currentDate,
                [pax stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                [tempArray[i] objectForKey:@"rssi"],
                [[[UIDevice currentDevice] identifierForVendor] UUIDString],
                BeaconAppIdPOST, BeaconKeyPOST];
                        
                NSLog(@"postBeaconFoundToAPI: %@", postBeaconFoundToAPI);
                    _region =  region;
                [HTTPRequestCreator prepareAndCallHTTP_GET_RequestWithURL:[NSURL URLWithString:postBeaconFoundToAPI] AndRequestType:@"get" AndDelegate:self AndSuccessSelector:@selector(postBeaconsDone:) AndFailSelector:@selector(postBeaconsWentWrong:)];
                }
                break;
            }
        }

        items = tempArray;
        
        ImmediateItems =  [[NSMutableArray alloc] init];
        Nearitems =  [[NSMutableArray alloc] init];
        Faritems =  [[NSMutableArray alloc] init];
        NotInRangeItems =  [[NSMutableArray alloc] init];
        UnknownItems = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < tempArray.count; i++)
        {
            if([[tempArray[i] objectForKey:@"proximity"] isEqualToString:@"N/A"])
                [NotInRangeItems addObject:tempArray[i]];
            else if([[tempArray[i] objectForKey:@"proximity"] isEqualToString:@"Immediate"])
                [ImmediateItems addObject:tempArray[i]];
            else if([[tempArray[i] objectForKey:@"proximity"] isEqualToString:@"Near"])
                [Nearitems addObject:tempArray[i]];
            else if([[tempArray[i] objectForKey:@"proximity"] isEqualToString:@"Far"])
                [Faritems addObject:tempArray[i]];
            else if([[tempArray[i] objectForKey:@"proximity"] isEqualToString:@"Unknown"])
                [UnknownItems addObject:tempArray[i]];
        }
        
        [AppDelegate sharedAppDelegate].arrayOfBeaconsRanged = tempArray;
        if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive){
            [self.beaconsTableView reloadData];
        
            [((MapViewController *)self.navigationController.menuContainerViewController.rightMenuViewController) setBeacons];
        }
        
        [self stopBeaconsRanging];

        if ([beacons count] > 0) {
            _firstRangingFlag = 1;
            CLBeacon *beacon = [beacons objectAtIndex:0];
            NSString *_cnt = [[NSString alloc] initWithFormat:
                              @"Number of beacons is : %lu and the first one is %f away from you",
                              (unsigned long)[beacons count], beacon.accuracy];
            NSLog(@"%@", _cnt);
            
            if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
                ((ControlViewController *)self.navigationController.menuContainerViewController.leftMenuViewController).inRangeCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)[beacons count]];
            
        } else {
            NSLog(@"there are no beacons in range");
        }
    }
    [self stopBeaconsRanging];
}

- (void)postBeaconsDone:(ASIHTTPRequest *)request
{
    [HTTPRequestCreator logEndRESTAPICall:request];
    NSError *error;
    NSData *responsedata = [request responseData];
    NSDictionary *beacons = [NSJSONSerialization JSONObjectWithData:responsedata options:NSJSONReadingMutableLeaves error:&error];
    NSLog(@"postBeaconsDone: %@",beacons);
    
    NSString *DesccriptiveText = @"";
    
    if([beacons objectForKey:@"metaData"])
        if([[beacons objectForKey:@"metaData"] objectForKey:@"descriptiveText"])
        DesccriptiveText = [[beacons objectForKey:@"metaData"] objectForKey:@"descriptiveText"];
    
    if([DesccriptiveText isEqualToString:@""])
        DesccriptiveText = [NSString stringWithFormat:@"I'm the %@ beacon at %@ and I don't have descriptive text.", [beacons objectForKey:@"name"], [beacons objectForKey:@"location"]];
    
    [AppDelegate addLog:[NSString stringWithFormat:@"Beacon Found: %@", DesccriptiveText]];
    
    if( ((ControlViewController *)self.navigationController.menuContainerViewController.leftMenuViewController).notificationsSwitch.isOn ){
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = DesccriptiveText;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        
        //UILocalNotification *notification = [UILocalNotification new];
        //notification.alertBody = DesccriptiveText;
        //[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)postBeaconsWentWrong:(ASIHTTPRequest *)request
{
    [HTTPRequestCreator logEndRESTAPICall:request];
    NSLog(@"postBeaconsWentWrong : %@",[request error]);
}

- (void) stopBeaconsRanging{
    for (CLBeaconRegion *monitoredRegion in [_locationManager rangedRegions])
        [_locationManager stopRangingBeaconsInRegion:monitoredRegion];
    [self hideRangingLabel];
}

- (void) showBeaconsFromAPI
{
    ((ControlViewController *)self.navigationController.menuContainerViewController.leftMenuViewController).inRegistryCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)[AppDelegate sharedAppDelegate].arrayOfBeacons.count];
    
    if( _regionGranularityOn == REGION_UUID_MAJORID_MINORID ){
        if([[AppDelegate sharedAppDelegate] arrayOfBeacons].count > 0){
            for (int i = 0; i < [[AppDelegate sharedAppDelegate] arrayOfBeacons].count; i++) {
                NSDictionary *item = [[[AppDelegate sharedAppDelegate] arrayOfBeacons] objectAtIndex:i];
                CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:[item objectForKey:@"uuid"]] major:[[item objectForKey:@"majorId"] integerValue] minor:[[item objectForKey:@"minorId"] integerValue] identifier:[NSString stringWithFormat:@"BeaconTReg%d", i]];
                
                region.notifyOnEntry = TRUE;
                region.notifyOnExit = TRUE;
                region.notifyEntryStateOnDisplay = YES;
                [_locationManager startMonitoringForRegion:region];
                
                
                NSString *regionsBeingMonitoredKey = @"";
                regionsBeingMonitoredKey = [NSString stringWithFormat:@"%@/%@/%@",[region.proximityUUID UUIDString], region.major, region.minor ];
                NSMutableDictionary *regionBeingMonitoredDict =[[NSMutableDictionary alloc]init];
                [regionBeingMonitoredDict setValue:region.proximityUUID.UUIDString forKey:@"uuid"];
                [regionBeingMonitoredDict setValue:region.major forKey:@"major"];
                [regionBeingMonitoredDict setValue:region.minor forKey:@"minor"];
                [regionBeingMonitoredDict setValue:region.identifier forKey:@"identifier"];
                [regionBeingMonitoredDict setObject:@"" forKey:@"state"];
                [[AppDelegate sharedAppDelegate].regionsBeingMonitored setObject:  regionBeingMonitoredDict forKey: regionsBeingMonitoredKey];
                
            }
        }
    }else if(_regionGranularityOn == REGION_UUID){
        if([AppDelegate sharedAppDelegate].arrayOfUniqueUUIDs.count > 0){
            for (int i = 0; i < [AppDelegate sharedAppDelegate].arrayOfUniqueUUIDs.count; i++) {
                CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:[AppDelegate sharedAppDelegate].arrayOfUniqueUUIDs[i]] identifier:[NSString stringWithFormat:@"BeaconTReg%d", i]];
                region.notifyOnEntry = TRUE;
                region.notifyOnExit = TRUE;
                region.notifyEntryStateOnDisplay = YES;
                [_locationManager startMonitoringForRegion:region];
                
                NSString *regionsBeingMonitoredKey = @"";
                regionsBeingMonitoredKey = [NSString stringWithFormat:@"%@",[region.proximityUUID UUIDString] ];
                
                
                NSMutableDictionary *regionBeingMonitoredDict =[[NSMutableDictionary alloc]init];
                [regionBeingMonitoredDict setValue:region.proximityUUID.UUIDString forKey:@"uuid"];
                [regionBeingMonitoredDict setValue:region.major forKey:@"major"];
                [regionBeingMonitoredDict setValue:region.minor forKey:@"minor"];
                [regionBeingMonitoredDict setValue:region.identifier forKey:@"identifier"];
                [regionBeingMonitoredDict setObject:@"" forKey:@"state"];
                
                [[AppDelegate sharedAppDelegate].regionsBeingMonitored setObject:  regionBeingMonitoredDict forKey: regionsBeingMonitoredKey];

            }
        }
        
    }else{
        if([AppDelegate sharedAppDelegate].arrayOfUniqueMajorIDs.count > 0){
            for (int i = 0; i < [AppDelegate sharedAppDelegate].arrayOfUniqueMajorIDs.count; i++) {
                
                NSArray* UUIDMajorArr = [[AppDelegate sharedAppDelegate].arrayOfUniqueMajorIDs[i] componentsSeparatedByString: @" "];
                
                CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:UUIDMajorArr[0]] major: [UUIDMajorArr[1] integerValue] identifier:[NSString stringWithFormat:@"BeaconTReg%d", i]];
                region.notifyOnEntry = TRUE;
                region.notifyOnExit = TRUE;
                region.notifyEntryStateOnDisplay = YES;
                [_locationManager startMonitoringForRegion:region];
                
                
                NSString *regionsBeingMonitoredKey = @"";
                regionsBeingMonitoredKey = [NSString stringWithFormat:@"%@/%@",[region.proximityUUID UUIDString], region.major ];
                
                
                NSMutableDictionary *regionBeingMonitoredDict =[[NSMutableDictionary alloc]init];
                [regionBeingMonitoredDict setValue:region.proximityUUID.UUIDString forKey:@"uuid"];
                [regionBeingMonitoredDict setValue:region.major forKey:@"major"];
                [regionBeingMonitoredDict setValue:region.minor forKey:@"minor"];
                [regionBeingMonitoredDict setValue:region.identifier forKey:@"identifier"];
                [regionBeingMonitoredDict setObject:@"" forKey:@"state"];
                
                [[AppDelegate sharedAppDelegate].regionsBeingMonitored setObject:  regionBeingMonitoredDict forKey: regionsBeingMonitoredKey];

            }
        }
    }
    
    [self clearForBlueToothRanging];
    NSMutableArray *updatedBeaconsArray = [[NSMutableArray alloc] init];
    for(id currBeaconFromAPI in [[AppDelegate sharedAppDelegate] arrayOfBeacons]){
        NSDictionary *item = currBeaconFromAPI;
        NSMutableDictionary *tempBeacon = [[NSMutableDictionary alloc] init];
        [tempBeacon setObject:@"-" forKey:@"Action"];
        [tempBeacon setObject:[item valueForKey:@"name"] forKey:@"name"];
        [tempBeacon setObject:[item valueForKey:@"location"] forKey:@"location"];
        [tempBeacon setObject:[item objectForKey:@"uuid"] forKey:@"uuid"];
        [tempBeacon setObject:[item objectForKey:@"majorId"] forKey:@"majorId"];
        [tempBeacon setObject:[item objectForKey:@"minorId"] forKey:@"minorId"];
        [tempBeacon setObject:[item objectForKey:@"beaconType"] forKey:@"beaconType"];
        [tempBeacon setObject:NotInRange_BeaconColor forKey:@"team-color"];
        [tempBeacon setObject:@"" forKey:@"picture"];
        [tempBeacon setObject:@"N/A" forKey:@"proximity"];
        [tempBeacon setObject:[item objectForKey:@"latitude"] forKey:@"latitude"];
        [tempBeacon setObject:[item objectForKey:@"longitude"] forKey:@"longitude"];
        [tempBeacon setObject:[item objectForKey:@"beaconType"] forKey:@"beaconType"];
        [tempBeacon setObject:[item objectForKey:@"airside"] forKey:@"airside"];
        [tempBeacon setObject:[item objectForKey:@"publicBeacon"] forKey:@"publicBeacon"];
        [tempBeacon setObject:[item objectForKey:@"idBeacon"] forKey:@"idBeacon"];
        [tempBeacon setObject:[item objectForKey:@"floor"] forKey:@"floor"];
        [tempBeacon setObject:[item objectForKey:@"advertisingInterval"] forKey:@"advertisingInterval"];
        [tempBeacon setObject:[item objectForKey:@"hardwareVersion"] forKey:@"hardwareVersion"];
        
        if( [item objectForKey:@"brandName"] )
            [tempBeacon setObject:[item objectForKey:@"brandName"] forKey:@"brandName"];
        
        [tempBeacon setObject:[[item objectForKey:@"organisation"] objectForKey:@"idOrganisation"] forKey:@"idOrganisation"];
        [tempBeacon setObject:[[item objectForKey:@"organisation"] objectForKey:@"name"] forKey:@"orgName"];
        [tempBeacon setObject:[[item objectForKey:@"organisation"] objectForKey:@"systemName"] forKey:@"systemName"];
        [tempBeacon setObject:[item objectForKey:@"dateAdded"] forKey:@"dateAdded"];
        [tempBeacon setObject:[item objectForKey:@"lastUpdate"] forKey:@"lastUpdate"];
        [tempBeacon setObject:[item objectForKey:@"macAddress"] forKey:@"macAddress"];
        
        if([item objectForKey:@"metaData"])
            [tempBeacon setObject:[item objectForKey:@"metaData"] forKey:@"metaData"];
        
        [tempBeacon setObject:[item objectForKey:@"power"] forKey:@"power"];
        [tempBeacon setObject:[item objectForKey:@"softwareVersion"] forKey:@"softwareVersion"];
        [tempBeacon setObject:@"N/A" forKey:@"rssi"];
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
        NSDate *formattedDate = [dateFormatter dateFromString:[item objectForKey:@"lastUpdate"]];
        
        NSLog(@"%ld", (long)[self daysBetweenDates:formattedDate andDate:[NSDate date]]);
        if( (long)[self daysBetweenDates:formattedDate andDate:[NSDate date]] > 6 )
            [tempBeacon setObject:NotInRange_BeaconColor forKey:@"team-color"];
        
        [updatedBeaconsArray insertObject:tempBeacon atIndex:updatedBeaconsArray.count];
    }
    
    items = updatedBeaconsArray;
    
    ImmediateItems =  [[NSMutableArray alloc] init];
    Nearitems =  [[NSMutableArray alloc] init];
    Faritems =  [[NSMutableArray alloc] init];
    NotInRangeItems =  [[NSMutableArray alloc] init];
    UnknownItems =  [[NSMutableArray alloc] init];
    
    for(int i = 0; i < updatedBeaconsArray.count; i++)
    {
        if([[updatedBeaconsArray[i] objectForKey:@"proximity"] isEqualToString:@"N/A"])
            [NotInRangeItems addObject:updatedBeaconsArray[i]];
        else if([[updatedBeaconsArray[i] objectForKey:@"proximity"] isEqualToString:@"Immediate"])
            [ImmediateItems addObject:updatedBeaconsArray[i]];
        else if([[updatedBeaconsArray[i] objectForKey:@"proximity"] isEqualToString:@"Near"])
            [Nearitems addObject:updatedBeaconsArray[i]];
        else if([[updatedBeaconsArray[i] objectForKey:@"proximity"] isEqualToString:@"Far"])
            [Faritems addObject:updatedBeaconsArray[i]];
        else if([[updatedBeaconsArray[i] objectForKey:@"proximity"] isEqualToString:@"Unknown"])
            [UnknownItems addObject:updatedBeaconsArray[i]];
    }
    [self.beaconsTableView reloadData];
}

- (NSString *)textForProximity:(CLProximity)proximity
{
    switch (proximity) {
        case CLProximityFar:
            return @"Far";
            break;
        case CLProximityNear:
            return @"Near";
            break;
        case CLProximityImmediate:
            return @"Immediate";
            break;
        default:
            return @"Unknown";
            break;
    }
}

- (NSInteger)daysBetweenDates:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

#pragma mark -
#pragma mark - UIBarButtonItems

- (void)setupMenuBarButtonItems {
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"MenuIcon"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"MapIcon"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(rightSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow"]
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(backButtonPressed:)];
}


#pragma mark -
#pragma mark - UIBarButtonItem Callbacks

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

- (void)rightSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark Table View Functions

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch(section) {
        case 0:
            count =  self.ImmediateItems.count;
            break;
        case 1:
            count =  self.Nearitems.count;
            break;
        case 2:
            count =  self.Faritems.count;
            break;
        case 3:
            count =  self.UnknownItems.count;
            break;
        case 4:
            count =  self.NotInRangeItems.count;
            break;
    }
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    int height = 30;
    
    if(section == 0)
        if(ImmediateItems.count == 0)
            height = 0;
    if(section == 1)
        if(Nearitems.count == 0)
            height = 0;
    if(section == 2)
        if(Faritems.count == 0)
            height = 0;
    if(section == 3)
        if(UnknownItems.count == 0)
            height = 0;
    if(section == 4)
        if(NotInRangeItems.count == 0)
            height = 0;
    
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = @"";
    
    switch(section) {
        case 0:
            sectionTitle = @"Immediate";
            break;
        case 1:
            sectionTitle = @"Near";
            break;
        case 2:
            sectionTitle = @"Far";
            break;
        case 3:
            sectionTitle = @"Unknown";
            break;
        case 4:
            sectionTitle = @"Not in range";
            break;
    }
    
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
    title.text = sectionTitle;
    title.textColor = [UIColor whiteColor];
    title.backgroundColor = [UIColor clearColor];
    
    UIView * whiteview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    whiteview.backgroundColor=[UIColor darkGrayColor];
    [whiteview addSubview:title];
    
    if(section == 0)
        if(ImmediateItems.count == 0)
            whiteview = nil;
    if(section == 1)
        if(Nearitems.count == 0)
           whiteview = nil;
    if(section == 2)
        if(Faritems.count == 0)
            whiteview = nil;
    if(section == 3)
        if(UnknownItems.count == 0)
            whiteview = nil;
    if(section == 4)
        if(NotInRangeItems.count == 0)
            whiteview = nil;
    
    return whiteview ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
    {  cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        type = 0;
    }
    
    NSDictionary *item;
    switch(indexPath.section) {
        case 0:
            item = [self.ImmediateItems objectAtIndex:indexPath.item];
            break;
        case 1:
            item = [self.Nearitems objectAtIndex:indexPath.item];
            break;
        case 2:
            item = [self.Faritems objectAtIndex:indexPath.item];
            break;
        case 3:
             item = [self.UnknownItems objectAtIndex:indexPath.item];
            break;
        case 4:
            item = [self.NotInRangeItems objectAtIndex:indexPath.item];
            break;
    }
    
    NSString *Brand = [item valueForKey:@"name"];
    //if([[item objectForKey:@"uuid"] isEqualToString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"])
    //    Brand = @"Estimote";
    //else if(
    //        [[item objectForKey:@"uuid"] isEqualToString:@"FD7B7966-9C0F-471A-83A2-46D995AE85A1"] ||
    //        [[item objectForKey:@"uuid"] isEqualToString:@"1AE18C1C-6C7B-4AED-B166-4462634DA855"] ||
    //        [[item objectForKey:@"uuid"] isEqualToString:@"9BF0D683-D4D7-441E-9A78-19461916A0D1"] ||
    //        [[item objectForKey:@"uuid"] isEqualToString:@"A33C916A-1871-40E2-9E0B-E914E8008DA1"] ||
    //        [[item objectForKey:@"uuid"] isEqualToString:@"57261C73-CF73-4A2B-9AB0-C4E1704ED597"] ||
    //        [[item objectForKey:@"uuid"] isEqualToString:@"114A4DD8-5B2F-4800-A079-BDCB21392BE9"] ||
    //        [[item objectForKey:@"uuid"] isEqualToString:@"A6702217-BDC4-45F4-8198-9B7A6E979AB3"] ||
    //        [[item objectForKey:@"uuid"] isEqualToString:@"00051DF7-29BC-48FC-B248-2699AFAEF461"]
    //        )
    //    Brand = @"SticknFind";
    //else if([[item objectForKey:@"uuid"] isEqualToString:@"61687109-905F-4436-91F8-E602F514C96D"])
    //    Brand = @"BlueCats";
    
    UILabel *BrandLabel = (UILabel*)[cell viewWithTag:101];
    [BrandLabel setText:Brand];
    UILabel *majorLabel = (UILabel*)[cell viewWithTag:104];
    [majorLabel setText:[NSString stringWithFormat:@"%ld",(long)[[item valueForKey:@"majorId"] integerValue]]];
    
    UILabel *minorLabel = (UILabel*)[cell viewWithTag:106];
    [minorLabel setText:[NSString stringWithFormat:@"%ld",(long)[[item valueForKey:@"minorId"] integerValue]]];
    
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:107];
    [nameLabel setText:[item valueForKey:@"name"]];
    
    UILabel *typeLabel = (UILabel*)[cell viewWithTag:108];
    [typeLabel setText:[item valueForKey:@"beaconType"]];
    
    UILabel *rssiLabel = (UILabel*)[cell viewWithTag:109];
    [rssiLabel setText:[item valueForKey:@"rssi"]];
    NSString *hexColor = [item valueForKey:@"team-color"];
    
    if(type == 0){
        UIView *borderView = [cell viewWithTag:102];
        for (id subview in [[[borderView layer] sublayers] copy])
        {
            if([subview isKindOfClass:[PulsingHaloLayer class]])
                [subview removeFromSuperlayer];
        }
        
        borderView.layer.borderWidth = 1;
        borderView.layer.borderColor = [self colorFromHex:hexColor].CGColor;
        borderView.layer.cornerRadius = 24.5;
        
        NSString *imgURL = [item valueForKey:@"picture"];
        //if([[item objectForKey:@"uuid"] isEqualToString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"])
        //    imgURL =@"icon-beacon.png";
        //else if(
        //        [[item objectForKey:@"uuid"] isEqualToString:@"FD7B7966-9C0F-471A-83A2-46D995AE85A1"] ||
        //        [[item objectForKey:@"uuid"] isEqualToString:@"1AE18C1C-6C7B-4AED-B166-4462634DA855"] ||
        //        [[item objectForKey:@"uuid"] isEqualToString:@"9BF0D683-D4D7-441E-9A78-19461916A0D1"] ||
        //        [[item objectForKey:@"uuid"] isEqualToString:@"A33C916A-1871-40E2-9E0B-E914E8008DA1"] ||
        //        [[item objectForKey:@"uuid"] isEqualToString:@"57261C73-CF73-4A2B-9AB0-C4E1704ED597"] ||
        //        [[item objectForKey:@"uuid"] isEqualToString:@"114A4DD8-5B2F-4800-A079-BDCB21392BE9"] ||
        //        [[item objectForKey:@"uuid"] isEqualToString:@"A6702217-BDC4-45F4-8198-9B7A6E979AB3"] ||
        //        [[item objectForKey:@"uuid"] isEqualToString:@"00051DF7-29BC-48FC-B248-2699AFAEF461"]
        //        )
        //    imgURL =@"SticknFind-Icon.png.png";
        //else if([[item objectForKey:@"uuid"] isEqualToString:@"61687109-905F-4436-91F8-E602F514C96D"])
        //    imgURL =@"BlueCats-Icon.png";
        
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:100];
        [imgView setImage:nil];
        imgView.layer.cornerRadius = 22.5;
        UIColor *color = [self colorFromHex:hexColor];
        
        if( ![[item valueForKey:@"proximity"] isEqualToString:@"N/A"] ){
            
            PulsingHaloLayer *halo = [[PulsingHaloLayer alloc] init];
            
            if( [[item valueForKey:@"proximity"] isEqualToString:@"Far"] )
                halo.animationDuration =  0.9;
            else if( [[item valueForKey:@"proximity"] isEqualToString:@"Near"] )
                halo.animationDuration = 0.65;
            else if( [[item valueForKey:@"proximity"] isEqualToString:@"Immediate"] )
                halo.animationDuration = 0.30;
            else
                halo.animationDuration = 1.25;
            
            halo.radius = 40;
            halo.backgroundColor = color.CGColor;
            halo.position = imgView.layer.position;
            [[cell viewWithTag:102].layer insertSublayer:halo below:[cell viewWithTag:100].layer];
        }
        
        __block UIImage *imageProduct = [thumbnailCache objectForKey:imgURL];
        if(imageProduct){
            
            imgView.image = imageProduct;
            [imgView setBackgroundColor:[self colorFromHex:hexColor]];
        }
        else{
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^{
                UIImage *image = [UIImage imageNamed:imgURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    imgView.image = image;
                    [imgView setBackgroundColor:[self colorFromHex:hexColor]];
                    [thumbnailCache setValue:image forKey:imgURL];
                });
            });
        }
        
    }else{
        nameLabel.textColor = [self colorFromHex:hexColor];
    }
    

    cell.contentView.tag = indexPath.item;
    [cell setBackgroundColor: [UIColor colorWithRed:256 green:256 blue:256 alpha:1.0]];
    
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    separatorLineView.backgroundColor = [UIColor whiteColor]; // set color as you want.
    [cell.contentView addSubview:separatorLineView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Selected Val%ld: ", (long)indexPath.row);
}

- (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexInt];
    return hexInt;
}

-(UIColor*)colorFromHex:(NSString*)hexString{
    unsigned int hexint = [self intFromHexString:hexString];
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:1];
    
    return color;
}

-(void) updateBeaconList
{
    items = [[AppDelegate sharedAppDelegate] arrayOfBeacons];
    [self.beaconsTableView reloadData];
}


- (IBAction)btnStopRanging:(id)sender {
   NSLog(@"btnStopRanging");
     [self stopBeaconsRanging];
    
}

- (IBAction)btnStartRanging:(id)sender{
        NSLog(@"btnStartRanging");
    

    /**
     * Assumption is that there is only one UUID per airport
     */
    _region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:[AppDelegate sharedAppDelegate].arrayOfUniqueUUIDs[0]] identifier:[NSString stringWithFormat:@"BeaconTReg%d", 0]];
    
    
    [self stopBeaconsRanging];
    [self startRanging];
}

@end
