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
    #define googleMapSDK @"Google Maps KEY"
    #define BeaconAPIKey   @"SITA iBEACON REGISTRY KEY"
    #define appId   @"SITA iBEACON REGISTRY APP ID"
    #define AirportURL  @"https://atibeacon.api.aero/atibeacon/airports/4/"
    #define beaconsUrl  @"https://atibeacon.api.aero/atibeacon/beacons/1"
    #define BeaconDelay 10
    #define RanginInterval 1
    #define API_BeaconColor  @"87fc70"
    #define New_BeaconColor @"ff3b30"
    #define Stale_BeaconColor @"ff9500"
    #define NotInRange_BeaconColor @"898c90"
    #define MAjorsDictionary @{ @"1000":@"CheckinDesk", @"1100":@"Waypoint",@"1200":@"Gate",@"1300":@"Retail",@"1400":@"BaggageHall",@"1500":@"Lounge",@"1600":@"SecurityZone",@"1700":@"CarPark",@"1800":@"Exit",@"1900":@"SalesOffice",@"2000":@"Restaurant",@"2100":@"Other"}
#endif
