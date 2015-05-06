//
//  AppDelegate.h
//  BeaconTrac
//
//  Created by Bilal Itani on 3/26/14.
//  Copyright (c) 2014 ITXi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ControlViewController.h"
#import "CollectionViewController.h"
#import "MapViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>{
    __block UIBackgroundTaskIdentifier bgTask;
}

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (assign) int noPaxByDefault;
@property (assign) int regionGranularity;
@property float AppLatitude;
@property float AppLongitude;
@property (retain, nonatomic) NSMutableArray *arrayOfBeacons;
@property (retain, nonatomic) NSMutableArray *arrayOfBeaconsRanged;
@property (retain, nonatomic) NSMutableArray *arrayOfUniqueUUIDs;
@property (retain, nonatomic) NSMutableArray *arrayOfUniqueMajorIDs;
@property (retain, nonatomic) NSMutableDictionary *regionsBeingMonitored;

//@property (retain, nonatomic) NSMutableDictionary *brandNamesToUUIDs;

@property (retain, nonatomic) CollectionViewController *collectionViewController;
@property (retain, nonatomic) ControlViewController *leftViewController ;
@property (retain, nonatomic) MapViewController *rightViewController;
@property (retain, nonatomic) NSString *mainAirport;
@property (retain, nonatomic) NSTimer *rangingTimer;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
+ (AppDelegate *)sharedAppDelegate;
+ (NSMutableArray *) GetAirlineCodesArray;
+ (void) WriteProfile : (NSMutableDictionary*) profileObj;
+ (NSMutableDictionary *) GetProfile;
+ (void) addLog:(NSString *)logText;
+ (void) clearLogs;
+ (NSData *) postLogsDataToServer;
+ (NSMutableDictionary *) GetLog;
@property (retain, nonatomic) NSString *BeaconKey;
@property (retain, nonatomic) NSString *BeaconAppId;

-(void)addBeaconsLog:(NSArray *)beaconsArray;
- (void) clearBeaconsLogs;
- (NSMutableDictionary *) GetBeaconsLog;
- (void) postBeaconsLogToServer;

-(void) updateBeaconsAfterAddSaveDelete;
-(void) showBeaconsAfterPaxModify;
-(void) changeAirprot :(NSString *) airportCode;
-(void) updateRegionGranularity:(int) isOn;

@end

@interface RegionBeingMonitored : NSObject

@property NSString *uuid;
@property NSNumber *majorId;
@property NSNumber *minorId;

@end