//
//  ControlViewController.m
//  BeaconTrac
//
//  Created by Bilal Itani on 3/26/14.
//  Copyright (c) 2014 ITXi. All rights reserved.
//

#import "ControlViewController.h"
#import "MFSideMenu.h"
#import "AppConstants.h"
#import "AppDelegate.h"
#import "PaxModalViewController.h"

@interface ControlViewController ()
{
    GMSMapView *mapView_;
    NSMutableArray *arrayOfDisplayedElements;
}
@end

@implementation ControlViewController

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
    
    _inRangeView.layer.borderWidth = 1;
    _inRangeView.layer.borderColor = [UIColor clearColor].CGColor;
    _inRangeView.layer.cornerRadius = 10;
    
    _inRegistryView.layer.borderWidth = 1;
    _inRegistryView.layer.borderColor = [UIColor clearColor].CGColor;
    _inRegistryView.layer.cornerRadius = 10;
    
    _monitoredView.layer.borderWidth = 1;
    _monitoredView.layer.borderColor = [UIColor clearColor].CGColor;
    _monitoredView.layer.cornerRadius = 10;
    
    [_mainScroll setScrollEnabled:YES];
    
    if( [[UIScreen mainScreen] bounds].size.height == 480 )
        _mainScroll.contentSize = CGSizeMake(320, 1100);
    else
        _mainScroll.contentSize = CGSizeMake(320, 1000);
    
    UITapGestureRecognizer *granularityCellTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(granularityCellTapped:)];
    [_granularityCell.contentView addGestureRecognizer:granularityCellTap];
                               
    NSMutableDictionary *profileObj = [[NSMutableDictionary alloc]init];
    profileObj = [AppDelegate GetProfile];
    
    if( [profileObj objectForKey:@"paxInfo"] != nil ){
        _paxLabel.text = [profileObj objectForKey:@"paxInfo"];
        _flightLabel.text = [profileObj objectForKey:@"flightInfo"];
        
        if([[profileObj objectForKey:@"beaconNotification"] isEqualToString:@"1"])
            _notificationsSwitch.on =  TRUE;
        else
            _notificationsSwitch.on =  FALSE;
        
        if([[profileObj objectForKey:@"regionNotification"] isEqualToString:@"1"])
            _regionSwitch.on =  TRUE;
        else
            _regionSwitch.on =  FALSE;
        
        if([[profileObj objectForKey:@"regionGranularity"] isEqualToString:@"0"]){
            _regionGranularitySwitch = 0;
            _granularityLabel.text = @"UUID";
        }
        else if([[profileObj objectForKey:@"regionGranularity"] isEqualToString:@"1"]){
            _regionGranularitySwitch = 1;
            _granularityLabel.text = @"UUID + MajorID";
        }else{
            _regionGranularitySwitch = 2;
            _granularityLabel.text = @"UUID + MajorID + MinorID";
        }
    }else{
        _granularityLabel.text = @"UUID + MajorID";
        [_notificationsSwitch setOn:FALSE];
        [_regionSwitch setOn:TRUE];
        _regionGranularitySwitch = 1;
    }
    
    if( [[UIScreen mainScreen] bounds].size.height == 480 ){
        
       _SavedLegendView.frame = CGRectMake(_SavedLegendView.frame.origin.x, _SavedLegendView.frame.origin.y-50, _SavedLegendView.frame.size.width, _SavedLegendView.frame.size.height);
        _SavedLabel.frame = CGRectMake(_SavedLabel.frame.origin.x, _SavedLabel.frame.origin.y-50, _SavedLabel.frame.size.width, _SavedLabel.frame.size.height);
        
        _StaleLegendView.frame = CGRectMake(_StaleLegendView.frame.origin.x, _StaleLegendView.frame.origin.y-50, _StaleLegendView.frame.size.width, _StaleLegendView.frame.size.height);
        _StaleLabel.frame = CGRectMake(_StaleLabel.frame.origin.x, _StaleLabel.frame.origin.y-50, _StaleLabel.frame.size.width, _StaleLabel.frame.size.height);
        
        _NewLegendView.frame = CGRectMake(_NewLegendView.frame.origin.x, _NewLegendView.frame.origin.y-50, _NewLegendView.frame.size.width, _NewLegendView.frame.size.height);
        _NewLabel.frame = CGRectMake(_NewLabel.frame.origin.x, _NewLabel.frame.origin.y-50, _NewLabel.frame.size.width, _NewLabel.frame.size.height);
        
        [self.view bringSubviewToFront:_SavedLegendView];
        [self.view bringSubviewToFront:_SavedLabel];
        [self.view bringSubviewToFront:_StaleLegendView];
        [self.view bringSubviewToFront:_StaleLabel];
        [self.view bringSubviewToFront:_NewLegendView];
        [self.view bringSubviewToFront:_NewLabel];        
    }
    
    arrayOfDisplayedElements =[[NSMutableArray alloc] init];
    
    _SavedLegendView.layer.borderWidth = 1;
    _SavedLegendView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _SavedLegendView.layer.cornerRadius = 23.5;
    [_SavedLegendView setBackgroundColor:[self colorFromHex:API_BeaconColor]];
    
    _StaleLegendView.layer.borderWidth = 1;
    _StaleLegendView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _StaleLegendView.layer.cornerRadius = 23.5;
    [_StaleLegendView setBackgroundColor:[self colorFromHex:Stale_BeaconColor]];
    
    _NewLegendView.layer.borderWidth = 1;
    _NewLegendView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _NewLegendView.layer.cornerRadius = 23.5;
    [_NewLegendView setBackgroundColor:[self colorFromHex:New_BeaconColor]];
    
    _appVersionLabel.text = [NSString stringWithFormat:@"%@ %@-%@", @"BeaconTrac V",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    if( [[UIScreen mainScreen] bounds].size.height == 480 )
        [_appVersionLabel setFrame:CGRectMake(5, _mainScroll.contentSize.height-110, 200, 16)];
    else
        [_appVersionLabel setFrame:CGRectMake(5, _mainScroll.contentSize.height-35, 200, 16)];
}

- (IBAction)saveNotifications:(id)sender{
    NSMutableDictionary *profileObj = [[NSMutableDictionary alloc]init];
    [profileObj setObject:_paxLabel.text forKey:@"paxInfo"];
    [profileObj setObject:_flightLabel.text forKey:@"flightInfo"];
    
    if(_notificationsSwitch.isOn == TRUE)
        [profileObj setObject:@"1" forKey:@"beaconNotification"];
    else
        [profileObj setObject:@"0" forKey:@"beaconNotification"];
    
    if(_regionSwitch.isOn == TRUE)
        [profileObj setObject:@"1" forKey:@"regionNotification"];
    else
        [profileObj setObject:@"0" forKey:@"regionNotification"];
    
    if( _regionGranularitySwitch == 0 ){
        [profileObj setObject:@"0" forKey:@"regionGranularity"];
        _granularityLabel.text = @"UUID";
    }
    else if([[profileObj objectForKey:@"regionGranularity"] isEqualToString:@"1"]){
        [profileObj setObject:@"1" forKey:@"regionGranularity"];
        _granularityLabel.text = @"UUID + MajorID";
    }else{
        [profileObj setObject:@"2" forKey:@"regionGranularity"];
        _granularityLabel.text = @"UUID + MajorID + MinorID";
    }
    [AppDelegate WriteProfile:profileObj];
}

- (void)changeRegionGranularity{
    NSMutableDictionary *profileObj = [[NSMutableDictionary alloc]init];
    [profileObj setObject:_paxLabel.text forKey:@"paxInfo"];
    [profileObj setObject:_flightLabel.text forKey:@"flightInfo"];
    
    if(_notificationsSwitch.isOn == TRUE)
        [profileObj setObject:@"1" forKey:@"beaconNotification"];
    else
        [profileObj setObject:@"0" forKey:@"beaconNotification"];
    
    if(_regionSwitch.isOn == TRUE)
        [profileObj setObject:@"1" forKey:@"regionNotification"];
    else
        [profileObj setObject:@"0" forKey:@"regionNotification"];
    
    int isOn = 0;
    
    if( _regionGranularitySwitch == 0 ){
        [profileObj setObject:@"0" forKey:@"regionGranularity"];
        _granularityLabel.text = @"UUID";
        isOn = 0;
    }
    else if(_regionGranularitySwitch == 1 ){
        [profileObj setObject:@"1" forKey:@"regionGranularity"];
        _granularityLabel.text = @"UUID + MajorID";
        isOn = 1;
    }else{
        [profileObj setObject:@"2" forKey:@"regionGranularity"];
        _granularityLabel.text = @"UUID + MajorID + MinorID";
        isOn = 2;
    }
    
    [AppDelegate WriteProfile:profileObj];
    [[AppDelegate sharedAppDelegate] updateRegionGranularity:isOn];
}

- (void)granularityCellTapped:(UITapGestureRecognizer *)recognizer
{
    PaxModalViewController *list = [[PaxModalViewController alloc] initWithNibName:@"PaxModalViewController" bundle:nil];
    list.Beacondelegate = self;
    list.modalType = @"2";
    
    NSMutableDictionary *profileObj = [[NSMutableDictionary alloc]init];
    [profileObj setObject:_paxLabel.text forKey:@"paxInfo"];
    NSArray *flightInfo = [_flightLabel.text componentsSeparatedByString:@" "];
    [profileObj setObject:flightInfo[0] forKey:@"airlineInfo"];
    [profileObj setObject:flightInfo[1] forKey:@"flightInfo"];
    list.profileVals = profileObj;
    [self presentViewController:list animated:YES completion:nil];
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

- (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexInt];
    return hexInt;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setMapInControlView :(NSString *) Latitude :(NSString *) Longtitude :(NSString *) title :(NSString * ) snippet
{
    NSLog(@"%@",Latitude);
    NSLog(@"%@",Longtitude);
   
    for (UIView *subview in [self.mapview subviews]) {
        
        [subview removeFromSuperview];
    }
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[Latitude floatValue]
                                                            longitude:[Longtitude floatValue]
                                                                 zoom:14];
    mapView_ = [GMSMapView mapWithFrame:self.mapview.bounds camera:camera];
    [self.mapview insertSubview:mapView_ atIndex:0];
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([Latitude floatValue], [Longtitude floatValue]);
    marker.title = title;
    marker.snippet = snippet;
    marker.map = mapView_;
    mapView_.selectedMarker=marker;
    
    [self.mapview setUserInteractionEnabled:NO];
}

#pragma mark Table View Functions
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( [AppDelegate sharedAppDelegate].regionGranularity == 0 ){
        _monitoredCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[AppDelegate sharedAppDelegate].arrayOfUniqueUUIDs.count];
        return [AppDelegate sharedAppDelegate].arrayOfUniqueUUIDs.count;
    }
    else if( [AppDelegate sharedAppDelegate].regionGranularity == 2 ){
    _monitoredCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[AppDelegate sharedAppDelegate].arrayOfBeacons.count];
        return [AppDelegate sharedAppDelegate].arrayOfBeacons.count;
    }else{
        _monitoredCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[AppDelegate sharedAppDelegate].arrayOfUniqueMajorIDs.count];
        return [AppDelegate sharedAppDelegate].arrayOfUniqueMajorIDs.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    }
    
    if( [AppDelegate sharedAppDelegate].regionGranularity == 0 )
        cell.textLabel.text = [[AppDelegate sharedAppDelegate].brandNamesToUUIDs objectForKey:[AppDelegate sharedAppDelegate].arrayOfUniqueUUIDs[indexPath.row]];
    else if( [AppDelegate sharedAppDelegate].regionGranularity == 1 ){
        
        NSArray *uuidMajor = [[AppDelegate sharedAppDelegate].arrayOfUniqueMajorIDs[indexPath.row] componentsSeparatedByString:@" "];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [[AppDelegate sharedAppDelegate].brandNamesToUUIDs objectForKey:[AppDelegate sharedAppDelegate].arrayOfUniqueMajorIDs[indexPath.row]], uuidMajor[1]];
    }
    else
        cell.textLabel.text = [[AppDelegate sharedAppDelegate].arrayOfBeacons [indexPath.row] objectForKey:@"name"];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 1)];
    separatorLineView.backgroundColor = [UIColor darkGrayColor];
    [cell.contentView addSubview:separatorLineView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

- (IBAction)ModifyPAX:(id)sender{
    PaxModalViewController *list = [[PaxModalViewController alloc] initWithNibName:@"PaxModalViewController" bundle:nil];
    list.Beacondelegate = self;
    list.modalType = @"1";
    
    NSMutableDictionary *profileObj = [[NSMutableDictionary alloc]init];
    [profileObj setObject:_paxLabel.text forKey:@"paxInfo"];
    NSArray *flightInfo = [_flightLabel.text componentsSeparatedByString:@" "];
    [profileObj setObject:flightInfo[0] forKey:@"airlineInfo"];
    [profileObj setObject:flightInfo[1] forKey:@"flightInfo"];
    list.profileVals = profileObj;
    [self presentViewController:list animated:YES completion:nil];
}

- (IBAction)SendLogs:(id)sender{

    [AppDelegate postLogsDataToServer];
}


- (void)shoModifyPAX{
    PaxModalViewController *list = [[PaxModalViewController alloc] initWithNibName:@"PaxModalViewController" bundle:nil];
    list.Beacondelegate = self;
    list.modalType = @"1";
    NSMutableDictionary *profileObj = [[NSMutableDictionary alloc]init];
    if( [self.paxLabel.text isEqualToString:@""] ){
        [profileObj setValue:@"" forKey:@"paxInfo"];
        [profileObj setValue:@" " forKey:@"airlineInfo"];
        [profileObj setValue:@"" forKey:@"flightInfo"];
    }else{
        [profileObj setObject:_paxLabel.text forKey:@"paxInfo"];
        NSArray *flightInfo = [_flightLabel.text componentsSeparatedByString:@" "];
        [profileObj setObject:flightInfo[0] forKey:@"airlineInfo"];
        [profileObj setObject:flightInfo[1] forKey:@"flightInfo"];
    }
    list.profileVals = profileObj;
    
    [self presentViewController:list animated:YES completion:nil];
}

@end
