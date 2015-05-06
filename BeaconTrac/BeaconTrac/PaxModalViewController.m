//
//  PaxModalViewController.m
//  BeaconTrac
//
//  Created by Bilal Itani on 4/28/14.
//  Copyright (c) 2014 ITXi. All rights reserved.
//

#import "PaxModalViewController.h"
#import "OptionsViewController.h"
#import "AppDelegate.h"
@interface PaxModalViewController ()

@end

@implementation PaxModalViewController{
    NSMutableArray *AirlineCodesArray;
}

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
    // Do any additional setup after loading the view from its nib.
    
    if( [self.modalType isEqualToString:@"1"] ){
        _GranularityView.hidden = YES;
        _RegisterView.hidden = NO;
        
        AirlineCodesArray=[[NSMutableArray alloc] init];
        [AirlineCodesArray setArray:[AppDelegate GetAirlineCodesArray]];
        
        _airlineCell.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectAirline)];
        [_airlineCell addGestureRecognizer:tapGesture];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(dismissKeyboard)];
        [self.view addGestureRecognizer:tap];
        
        _paxEmail.text = [_profileVals objectForKey:@"paxInfo"];
        _airlineValue.text = [_profileVals objectForKey:@"airlineInfo"];
        _flightNumber.text = [_profileVals objectForKey:@"flightInfo"];
        
        if([_paxEmail.text isEqualToString:@""]){
            _navigationItemCustom.leftBarButtonItem.title = @"";
            _navigationItemCustom.rightBarButtonItem.title = @"Continue";
            [AppDelegate sharedAppDelegate].noPaxByDefault = 1;
            
            _airlineValue.text = @"XS";
            _flightNumber.text = @"0001";
        }
    }else{
        _navigationItemCustom.leftBarButtonItem.title = @"Cancel";
        _navigationItemCustom.rightBarButtonItem.title = @"";
        
        _GranularityView.hidden = NO;
        _RegisterView.hidden = YES;
        _descriptionLabel.text = @"Select region granularity";
        
        UITapGestureRecognizer *granularityCellTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(granularityCellTapped:)];
        [_uuidRegion addGestureRecognizer:granularityCellTap];
        granularityCellTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(granularityCellTapped:)];
        [_majorRegion addGestureRecognizer:granularityCellTap];
        granularityCellTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(granularityCellTapped:)];
        [_minorRegion addGestureRecognizer:granularityCellTap];
        
        if( [self.Beacondelegate.granularityLabel.text isEqualToString:@"UUID"] ){
            _uuidRegion.accessoryType = UITableViewCellAccessoryCheckmark;
        }else if([self.Beacondelegate.granularityLabel.text isEqualToString:@"UUID + MajorID"]){
            _majorRegion.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            _minorRegion.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        if( [AppDelegate sharedAppDelegate].arrayOfUniqueMajorIDs.count > 20 ){
            [_majorRegion setBackgroundColor:[UIColor lightGrayColor]];
            _majorRegion.userInteractionEnabled = NO;
        }
        
        if( [AppDelegate sharedAppDelegate].arrayOfBeacons.count > 20 ){
            [_minorRegion setBackgroundColor:[UIColor lightGrayColor]];
            _minorRegion.userInteractionEnabled = NO;
        }
    }
}

- (void)granularityCellTapped:(UITapGestureRecognizer *)recognizer
{
    _uuidRegion.accessoryType = UITableViewCellAccessoryNone;
    _majorRegion.accessoryType = UITableViewCellAccessoryNone;
    _minorRegion.accessoryType = UITableViewCellAccessoryNone;
    
    if( recognizer.view.tag == 0 ){
        _uuidRegion.accessoryType = UITableViewCellAccessoryCheckmark;
        self.Beacondelegate.granularityLabel.text = _uuidRegion.textLabel.text;
        self.Beacondelegate.regionGranularitySwitch = REGION_UUID;
    }else if(recognizer.view.tag == 1){
        _majorRegion.accessoryType = UITableViewCellAccessoryCheckmark;
        self.Beacondelegate.granularityLabel.text = _majorRegion.textLabel.text;
        self.Beacondelegate.regionGranularitySwitch = REGION_UUID_MAJORID;
    }else{
        _minorRegion.accessoryType = UITableViewCellAccessoryCheckmark;
        self.Beacondelegate.granularityLabel.text = _minorRegion.textLabel.text;
        self.Beacondelegate.regionGranularitySwitch = REGION_UUID_MAJORID_MINORID;
    }
    [self.Beacondelegate changeRegionGranularity];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) dismissKeyboard{
    [_paxEmail resignFirstResponder];
    [_flightNumber resignFirstResponder];
}

-(void) selectAirline{
    OptionsViewController *optionsViewController;
    optionsViewController =[[OptionsViewController alloc] initWithNibName:@"OptionsViewController" bundle:nil];

    optionsViewController.tag = 3;
    optionsViewController.optionViewTitle = @"Select Airline";
    optionsViewController.delegate = self;
    optionsViewController.listOfOptions = AirlineCodesArray;
    optionsViewController.Filter = @"True";
    optionsViewController.isSSR = @"No";
    optionsViewController.modalPresentationStyle = UIPopoverArrowDirectionUp;
    [self presentViewController:optionsViewController animated:YES completion:nil];
    
}

- (IBAction)DismissModal:(id)sender {
    
    if( [self.modalType isEqualToString:@"1"] ){
        if([AppDelegate sharedAppDelegate].noPaxByDefault == 0){
            if( [self.Beacondelegate.paxLabel.text isEqualToString:@""] || [self.Beacondelegate.flightLabel.text isEqualToString:@""] ){
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: @"PAX info required!"
                                      message: @"Please enter PAX info before proceeding."
                                      delegate: nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
            }else
                 [self dismissViewControllerAnimated:YES completion:nil];
        }
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)SaveModal:(id)sender {
    
    if( [self.modalType isEqualToString:@"1"] ){
            if( ![_paxEmail.text isEqualToString:@""] && ![_airlineValue.text isEqualToString:@""] && ![_airlineValue.text isEqualToString:@" "] && ![_flightNumber.text isEqualToString:@""] ){
                
                self.Beacondelegate.paxLabel.text = _paxEmail.text;
                self.Beacondelegate.flightLabel.text = [NSString stringWithFormat:@"%@ %@", _airlineValue.text, _flightNumber.text];
                NSMutableDictionary *profileObj = [[NSMutableDictionary alloc]init];
                [profileObj setObject:_paxEmail.text forKey:@"paxInfo"];
                [profileObj setObject:[NSString stringWithFormat:@"%@ %@", _airlineValue.text, _flightNumber.text] forKey:@"flightInfo"];
                
                if(self.Beacondelegate.notificationsSwitch.isOn == TRUE)
                    [profileObj setObject:@"1" forKey:@"beaconNotification"];
                else
                    [profileObj setObject:@"0" forKey:@"beaconNotification"];
                
                if(self.Beacondelegate.regionSwitch.isOn == TRUE)
                    [profileObj setObject:@"1" forKey:@"regionNotification"];
                else
                    [profileObj setObject:@"0" forKey:@"regionNotification"];
                
                if(self.Beacondelegate.regionGranularitySwitch == REGION_UUID)
                    [profileObj setObject:@"0" forKey:@"regionGranularity"];
                else if(self.Beacondelegate.regionGranularitySwitch == REGION_UUID_MAJORID)
                    [profileObj setObject:@"1" forKey:@"regionGranularity"];
                else
                    [profileObj setObject:@"2" forKey:@"regionGranularity"];
                
                [AppDelegate WriteProfile:profileObj];
                [[AppDelegate sharedAppDelegate] showBeaconsAfterPaxModify];
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }else{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: @"All Feilds Required"
                                      message: @"Please fill all fields before saving."
                                      delegate: nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
            }
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
