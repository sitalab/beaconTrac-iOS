//
//  Constants.h
//  BeaconTrac
//
//  Created by Bilal Itani on 3/29/14.
//  Copyright (c) 2014 ITXi. All rights reserved.
//

//#define NSLog

#ifndef BeaconTrac_Constants_h
    #define BeaconTrac_Constants_h
    #define FlurryKey   @"your_flurry_key"
    #define googleMapSDK @"your_google_map_key"

    #define BeaconAPIKey   @"your_beacon_api_key"
    #define appId   @"your_beacon_app_id_key"

    #define SIN_BeaconAPIKey   @"your_beacon_api_key"
    #define SIN_appId   @"your_beacon_app_id_key"

    #define AirportURL  @"https://cube.api.aero/atibeacon/airports/4/"
    #define beaconsUrl  @"https://cube.api.aero/atibeacon/beacons/1"
    #define beaconsReportingUrl  @"https://cube.api.aero/atibeacon/beacons/1/beaconDetectionReport"
    #define BeaconDelay 10
    #define RanginInterval 1
    #define API_BeaconColor  @"87fc70"
    #define New_BeaconColor @"ff3b30"
    #define Stale_BeaconColor @"ff9500"
    #define NotInRange_BeaconColor @"898c90"
    #define arrayOfLocactions   [NSArray arrayWithObjects:@"ITXI",@"SITA_ATL",@"SITA_BTN",@"SITA_GVA","CPH",nil]
    #define MAjorsDictionary @{ @"1000":@"CheckinDesk", @"1100":@"Waypoint",@"1200":@"Gate",@"1300":@"Retail",@"1400":@"BaggageHall",@"1500":@"Lounge",@"1600":@"SecurityZone",@"1700":@"CarPark",@"1800":@"Exit",@"1900":@"SalesOffice",@"2000":@"Restaurant",@"2100":@"Other",@"2200":@"TransitZone",@"2300":@"ArrivalsHall",@"2400":@"Kiosk",@"2500":@"Ramp"}
#endif
