//
//  AppDelegate.m
//  BeaconTrac
//
//  Created by Bilal Itani on 3/26/14.
//  Copyright (c) 2014 ITXi. All rights reserved.
//

#import "AppDelegate.h"
#import "MFSideMenuContainerViewController.h"
#import "HTTPRequestCreator.h"
#import "Constants.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Language.h"
#import "StringObject.h"

@implementation AppDelegate
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;

}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"application: didFinishLaunchingWithOptions");
    
    [Language setLanguage:@"en"];
    [GMSServices provideAPIKey:googleMapSDK];
    
    _noPaxByDefault = 0;
    _regionGranularity = 0;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.arrayOfBeacons = [[NSMutableArray alloc] init];
    self.arrayOfBeaconsRanged = [[NSMutableArray alloc] init];
    self.arrayOfUniqueUUIDs = [[NSMutableArray alloc] init];
    self.brandNamesToUUIDs = [[NSMutableDictionary alloc] init];
    self.arrayOfUniqueMajorIDs = [[NSMutableArray alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    geocoder = [[CLGeocoder alloc] init];
    [locationManager startUpdatingLocation];
    
    self.collectionViewController = [[CollectionViewController alloc] initWithNibName:@"CollectionViewController_iphone" bundle:Nil];
    self.leftViewController = [[ControlViewController alloc] initWithNibName:@"ControlViewController_iphone" bundle:Nil];
    self.rightViewController = [[MapViewController alloc] initWithNibName:@"MapViewController_iphone" bundle:Nil];
    
    UINavigationController *navigationControl=[[UINavigationController alloc] initWithRootViewController:self.collectionViewController];
    
    if([self.leftViewController.paxLabel.text isEqualToString:@""])
        _noPaxByDefault = 1;
    else
        _noPaxByDefault = 0;
    
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:navigationControl
                                                    leftMenuViewController:self.leftViewController
                                                    rightMenuViewController:self.rightViewController];
    self.window.rootViewController = container;
    [self.window makeKeyAndVisible];
    return YES;
}

+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if (application.backgroundRefreshStatus == 2){
        UIApplication *app = [UIApplication sharedApplication];
        //create new uiBackgroundTask
        __block UIBackgroundTaskIdentifier bgTask1 = [app beginBackgroundTaskWithExpirationHandler:^{
            [app endBackgroundTask:bgTask1];
            bgTask1 = UIBackgroundTaskInvalid;
        }];
        
        //and create new timer with async call:
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //run function methodRunAfterBackground
            if(_rangingTimer != nil){
                [_rangingTimer invalidate];
                _rangingTimer = nil;
            }
            _rangingTimer = [NSTimer scheduledTimerWithTimeInterval:RanginInterval target:self selector:@selector(startRanging) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_rangingTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        });
    }
}

- (void) startRanging {
    [self.collectionViewController startRanging];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if(_rangingTimer != nil){
        [_rangingTimer invalidate];
        _rangingTimer = nil;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"application: applicationDidBecomeActive");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

-(void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
        message:notification.alertBody
        delegate:self cancelButtonTitle:@"OK"
        otherButtonTitles:nil];
        alert.tag=111222;
    [alert show];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    // Request to reload table view data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BeaconTrac" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BeaconTrac.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{

}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"locationManager: didUpdateToLocation");
    NSLog(@"didUpdateToLocation: %@", newLocation);
    
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        _AppLatitude = newLocation.coordinate.latitude;
        _AppLongitude = newLocation.coordinate.longitude;
        [self.collectionViewController appIsLoadingBeacons];
        NSString *airportUrl=[NSString stringWithFormat:@"%@%f/%f?app_id=%@&app_key=%@",AirportURL,newLocation.coordinate.latitude,newLocation.coordinate.longitude,appId,BeaconAPIKey];
        
        NSURL  *url= [NSURL URLWithString:airportUrl];
        
        if( url != nil ){
            
            [HTTPRequestCreator prepareAndCallHTTP_GET_RequestWithURL:url AndRequestType:@"get" AndDelegate:self AndSuccessSelector:@selector(requestAirportSearchDone:) AndFailSelector:@selector(requestAirportSearchWentWrong:)];
        }else
                NSLog(@"Please set: googleMapSDK, SITA iBEACON REGISTRY KE, SITA iBEACON REGISTRY APP ID ");
        // Stop Location Manager
        [locationManager stopUpdatingLocation];
    }
}

- (void)requestAirportSearchDone:(ASIHTTPRequest *)request
{
    [HTTPRequestCreator logEndRESTAPICall:request];
    NSError *error;
    NSData *responsedata = [request responseData];
    NSLog(@"Response1: %@",responsedata.description);
    
    NSArray *airports = [NSJSONSerialization JSONObjectWithData:responsedata options:NSJSONReadingMutableLeaves error:&error];
    
    NSLog(@"Response2: %@",airports);
    if((NSNull *)airports!=[NSNull null])
    {
        if(airports.count>0)
        {
            NSLog(@"requestAirportSearchDone: 1");
            
            NSMutableDictionary *airportDict = [[NSMutableDictionary alloc] init];
            [airportDict setDictionary:airports[0]];
            
            if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive){
                [self.rightViewController setMapInControlView:[airportDict objectForKey:@"latitude"] :[airportDict objectForKey:@"longitude"]];
                [self.leftViewController setMapInControlView:[airportDict objectForKey:@"latitude"] :[airportDict objectForKey:@"longitude"] :[airportDict objectForKey:@"country"] :[airportDict objectForKey:@"city"]];
                self.leftViewController.currentLocationVal.text = [airportDict objectForKey:@"code"];
                [self.collectionViewController.navigationItem setTitle:[airportDict objectForKey:@"code"]];
            }
            
            self.mainAirport = [airportDict objectForKey:@"code"];
            NSString *listOfBeaconsUrl=[NSString stringWithFormat:@"%@?UserName=ziad@itx.net&airportCode=%@&app_id=%@&app_key=%@",beaconsUrl,[airportDict objectForKey:@"code"],appId,BeaconAPIKey];

            [HTTPRequestCreator prepareAndCallHTTP_GET_RequestWithURL:[NSURL URLWithString:listOfBeaconsUrl] AndRequestType:@"get" AndDelegate:self AndSuccessSelector:@selector(requestBeaconsSearchDone:) AndFailSelector:@selector(requestBeaconsSearchWentWrong:)];
            NSLog(@"requestAirportSearchDone: 3");
            
        }else{
            [self.collectionViewController noBeaconsLoaded];
        }
    }else{
        [self.collectionViewController noBeaconsLoaded];
    }
}

- (void)requestAirportSearchWentWrong:(ASIHTTPRequest *)request
{
    [HTTPRequestCreator logEndRESTAPICall:request];
    NSLog(@"request error: %@",[request error]);
    [self.collectionViewController noBeaconsLoaded];
}

- (void)requestBeaconsSearchDone:(ASIHTTPRequest *)request
{
    [HTTPRequestCreator logEndRESTAPICall:request];
    NSError *error;
    NSData *responsedata = [request responseData];
    
    NSArray *beacons = [NSJSONSerialization JSONObjectWithData:responsedata options:NSJSONReadingMutableLeaves error:&error];
    NSLog(@"Response2: %@",beacons);
    
    if(beacons.count > 0)
    {
        self.arrayOfBeacons = [[NSMutableArray alloc] init];
        self.arrayOfBeaconsRanged = [[NSMutableArray alloc] init];
        [self.arrayOfBeacons setArray:beacons];
        [self.arrayOfBeaconsRanged setArray:beacons];
        
        if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
            [self.rightViewController setMapInControlView:[beacons[0] objectForKey:@"latitude"] :[beacons[0] objectForKey:@"longitude"] ];
        
        _arrayOfUniqueUUIDs = [[NSMutableArray alloc] init];
        _brandNamesToUUIDs = [[NSMutableDictionary alloc] init];
        _arrayOfUniqueMajorIDs = [[NSMutableArray alloc] init];
        for (id currBeaconObj in beacons) {
            if( ![_arrayOfUniqueUUIDs containsObject:[currBeaconObj objectForKey:@"uuid"]] ){
                [_arrayOfUniqueUUIDs addObject:[currBeaconObj objectForKey:@"uuid"]];
                [_brandNamesToUUIDs setValue:[currBeaconObj objectForKey:@"brandName"] forKey:[currBeaconObj objectForKey:@"uuid"]];
            }
            
            NSString *UUIDMajor = @"";
            UUIDMajor = [NSString stringWithFormat:@"%@ %@", [currBeaconObj objectForKey:@"uuid"], [currBeaconObj objectForKey:@"majorId"] ];
            if( ![_arrayOfUniqueMajorIDs containsObject: UUIDMajor] ){
                [_arrayOfUniqueMajorIDs addObject:UUIDMajor];
                [_brandNamesToUUIDs setValue:[currBeaconObj objectForKey:@"brandName"] forKey:UUIDMajor];
            }
        }
        
        for (CLBeaconRegion *monitoredRegion in [locationManager monitoredRegions]){
            NSLog(@"monitoredRegion: %@", monitoredRegion);
            [locationManager stopMonitoringForRegion:monitoredRegion];
        }
        
        NSLog(@"%@",beacons);
        NSLog(@"Unique Beacons: %@",_arrayOfUniqueUUIDs);
        NSLog(@"UUIDs to Brands: %@", _brandNamesToUUIDs);
        NSLog(@"Unique Majors: %@", _arrayOfUniqueMajorIDs);
        
        if([self.leftViewController.paxLabel.text isEqualToString:@""])
            _noPaxByDefault = 1;
        else
            _noPaxByDefault = 0;
        
        if(_noPaxByDefault == 1){
            self.collectionViewController.regionGranularityOn = 1;
            _regionGranularity = 1;
        }
        
        if( _noPaxByDefault == 0){
            
            NSMutableDictionary *profileObj = [[NSMutableDictionary alloc]init];
            profileObj = [AppDelegate GetProfile];
            
            if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive){
                if( [profileObj objectForKey:@"paxInfo"] != nil ){
                    self.collectionViewController.regionGranularityOn = (int)[[profileObj objectForKey:@"regionGranularity"] integerValue];
                    _regionGranularity = (int)[[profileObj objectForKey:@"regionGranularity"] integerValue];
                }
                [self.collectionViewController updateBeaconList];
                [self.rightViewController setBeacons];
                [self.collectionViewController showBeaconsFromAPI];
                [self.leftViewController.locationsTableView reloadData];
            }else{
                if([[profileObj objectForKey:@"regionGranularity"] isEqualToString:@"2"]){
                    _regionGranularity = 2;
                    for (int i = 0; i < _arrayOfBeacons.count; i++) {
                        NSDictionary *item = [_arrayOfBeacons objectAtIndex:i];
                        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:[item objectForKey:@"uuid"]] major:[[item objectForKey:@"majorId"] integerValue] minor:[[item objectForKey:@"minorId"] integerValue] identifier:[NSString stringWithFormat:@"BeaconTReg%d", i]];
                        
                        region.notifyOnEntry = TRUE;
                        region.notifyOnExit = TRUE;
                        region.notifyEntryStateOnDisplay = YES;
                        [locationManager startMonitoringForRegion:region];
                    }
                }else if([[profileObj objectForKey:@"regionGranularity"] isEqualToString:@"0"]){
                        _regionGranularity = 0;
                        for (int i = 0; i < _arrayOfUniqueUUIDs.count; i++) {
                            CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:_arrayOfUniqueUUIDs[i]] identifier:[NSString stringWithFormat:@"BeaconTReg%d", i]];
                            region.notifyOnEntry = TRUE;
                            region.notifyOnExit = TRUE;
                            region.notifyEntryStateOnDisplay = YES;
                            [locationManager startMonitoringForRegion:region];
                        }
                }else{
                    _regionGranularity = 1;
                    for (int i = 0; i < _arrayOfUniqueMajorIDs.count; i++) {
                        
                        NSArray* UUIDMajorArr = [_arrayOfUniqueMajorIDs[i] componentsSeparatedByString: @" "];
                        
                        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:UUIDMajorArr[0]] major: [UUIDMajorArr[1] integerValue] identifier:[NSString stringWithFormat:@"BeaconTReg%d", i]];
                        region.notifyOnEntry = TRUE;
                        region.notifyOnExit = TRUE;
                        region.notifyEntryStateOnDisplay = YES;
                        [locationManager startMonitoringForRegion:region];
                    }
                }
            }
        }else{
            if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
                [self.collectionViewController noBeaconsLoaded];
        }
    }
    else
        if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
            [self.collectionViewController noBeaconsLoaded];
}

- (void)showBeaconsAfterPaxModify
{
    if( _noPaxByDefault == 1){
        _noPaxByDefault = 0;
        if(self.arrayOfBeacons.count > 0)
        {
            NSMutableDictionary *profileObj = [[NSMutableDictionary alloc]init];
            profileObj = [AppDelegate GetProfile];
            
            if( [profileObj objectForKey:@"paxInfo"] != nil ){
                self.collectionViewController.regionGranularityOn = (int)[[profileObj objectForKey:@"regionGranularity"] integerValue];
                _regionGranularity = (int)[[profileObj objectForKey:@"regionGranularity"] integerValue];
            }
            
            [self.collectionViewController updateBeaconList];
            [self.rightViewController setBeacons];
            [self.collectionViewController showBeaconsFromAPI];
            [self.leftViewController.locationsTableView reloadData];
        }
        else
            [self.collectionViewController noBeaconsLoaded];
        [self.collectionViewController closeMenu];
    }
}

- (void)requestBeaconsSearchWentWrong:(ASIHTTPRequest *)request
{
    [HTTPRequestCreator logEndRESTAPICall:request];
    NSLog(@"requestBeaconsSearchWentWrong: %@",[request error]);
    [self.collectionViewController noBeaconsLoaded];
}

-(void) changeAirprot :(NSString *) airportCode
{
    [self.collectionViewController appIsLoadingBeacons];
    [self.collectionViewController.navigationItem setTitle:airportCode];
    [self.collectionViewController stopBeaconsRanging];
    
    NSString *listOfBeaconsUrl=[NSString stringWithFormat:@"%@?airportCode=%@&app_id=%@&app_key=%@",beaconsUrl, airportCode, appId,BeaconAPIKey];
    
    [HTTPRequestCreator prepareAndCallHTTP_GET_RequestWithURL:[NSURL URLWithString:listOfBeaconsUrl] AndRequestType:@"get" AndDelegate:self AndSuccessSelector:@selector(requestBeaconsSearchDone:) AndFailSelector:@selector(requestBeaconsSearchWentWrong:)];
    self.leftViewController.currentLocationVal.text = airportCode;
}

-(void) updateBeaconsAfterAddSaveDelete
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    geocoder = [[CLGeocoder alloc] init];
    [locationManager startUpdatingLocation];
}

-(void) updateRegionGranularity:(int) isOn
{
    _regionGranularity = isOn;
    [self.leftViewController.locationsTableView reloadData];
    self.collectionViewController.regionGranularityOn = isOn;
    [self.collectionViewController switchToRegionGranularity];
}

+ (NSMutableArray *) GetAirlineCodesArray
{
    NSMutableArray *AirlineCodesArray=[[NSMutableArray alloc] init];
    // get paths from root direcory
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    // get documents path
    NSString *documentsPath = [paths objectAtIndex:0];
    // get the path to our Data/plist file
    NSString *path= [documentsPath stringByAppendingPathComponent:@"AirlineCodesArray.plist"];
    
    NSError *errorPath;
    
    // check to see if Data.plist exists in documents
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        // if not in documents, get property list from main bundle
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"AirlineCodesArray" ofType:@"plist"];
        
        [[NSFileManager defaultManager] copyItemAtPath:bundle toPath: path error:&errorPath]; //6
    }
    
    // read property list into memory as an NSData object
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    
    // convert static property list into dictionary object
    AirlineCodesArray = (NSMutableArray *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];

    return AirlineCodesArray;
}

+ (NSMutableDictionary *) GetProfile
{
    NSMutableDictionary *ProfileObject = [[NSMutableDictionary alloc] init];
    // get paths from root direcory
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    // get documents path
    NSString *documentsPath = [paths objectAtIndex:0];
    // get the path to our Data/plist file
    NSString *path= [documentsPath stringByAppendingPathComponent:@"Profile.plist"];
    
    NSError *errorPath;
    
    // check to see if Data.plist exists in documents
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        // if not in documents, get property list from main bundle
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Profile" ofType:@"plist"];
        [[NSFileManager defaultManager] copyItemAtPath:bundle toPath: path error:&errorPath];
    }
    
    // read property list into memory as an NSData object
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    
    // convert static property list into dictionary object
    ProfileObject = (NSMutableDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    
    
    [ProfileObject writeToFile:path atomically:YES];
    
    return ProfileObject;
}

+ (void) WriteProfile : (NSMutableDictionary*) profileObj
{
    NSMutableDictionary *ProfileObject = [[NSMutableDictionary alloc] init];
    // get paths from root direcory
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    // get documents path
    NSString *documentsPath = [paths objectAtIndex:0];
    // get the path to our Data/plist file
    NSString *path= [documentsPath stringByAppendingPathComponent:@"Profile.plist"];
    
    NSError *errorPath;
    
    // check to see if Data.plist exists in documents
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        // if not in documents, get property list from main bundle
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Profile" ofType:@"plist"];
        [[NSFileManager defaultManager] copyItemAtPath:bundle toPath: path error:&errorPath];
    }
    
    // read property list into memory as an NSData object
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    
    // convert static property list into dictionary object
    ProfileObject = (NSMutableDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    
    [ProfileObject setDictionary:profileObj];
    [ProfileObject writeToFile:path atomically:YES];
}

+(void)addLog:(NSString *)logText
{
    // get paths from root direcory
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    // get documents path
    NSString *documentsPath = [paths objectAtIndex:0];
    // get the path to our Data/plist file
    
    NSString *offlinePlist=[NSString stringWithFormat:@"BTracLogs.plist"];
    
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:offlinePlist];
    
    NSError *errorPath;
    // check to see if Data.plist exists in documents
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        // if not in documents, get property list from main bundle
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"BTracLogs" ofType:@"plist"];
        
        [[NSFileManager defaultManager] copyItemAtPath:bundle toPath: plistPath error:&errorPath]; //6
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        NSMutableDictionary *logsDictionary = [[NSMutableDictionary alloc] init];
        
        @try
        {
            if ([[NSKeyedUnarchiver unarchiveObjectWithFile:plistPath] isKindOfClass:[NSMutableDictionary class]]) {
                logsDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
            }
        }
        @catch (NSException *exception)
        {
            // NSLog(@"exception : %@",exception);
            // read property list into memory as an NSData object
            NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
            NSString *errorDesc = nil;
            NSPropertyListFormat format;
            // convert static property liost into dictionary object
            logsDictionary = (NSMutableDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
        }
        
        NSMutableArray *logsArray = [[NSMutableArray alloc] init];
        
        if (![logsDictionary objectForKey:@"startTime"]){
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
            [logsDictionary setObject:[formatter stringFromDate:[NSDate date]] forKey:@"startTime"];
        }else{
            if ([logsDictionary objectForKey:@"log"]) {
                [logsArray addObjectsFromArray:[logsDictionary objectForKey:@"log"]];
                [logsDictionary removeObjectForKey:@"log"];
            }
        }
        NSMutableDictionary *logData = [[NSMutableDictionary alloc] init];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        [logData setObject:[formatter stringFromDate:[NSDate date]] forKey:@"time"];
        [logData setObject:logText forKey:@"entry"];
        [logsArray addObject:logData];
        // NSLog(@"log added: %@",logData);
        [logsDictionary setObject:logsArray forKey:@"log"];
        
        if ([NSKeyedArchiver archiveRootObject:logsDictionary toFile:plistPath]) {
            // NSLog(@"success with NSKeyedArchiver cashing log data");
        }
    }
}

+ (void) clearLogs
{
    NSMutableDictionary *logsDict=[[NSMutableDictionary alloc] init];
    
    // get paths from root direcory
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    // get documents path
    NSString *documentsPath = [paths objectAtIndex:0];
    // get the path to our Data/plist file
    
    NSString *offlinePlist=[NSString stringWithFormat:@"BTracLogs.plist"];
    
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:offlinePlist];
    
    if ([NSKeyedArchiver archiveRootObject:logsDict toFile:plistPath]) {
        //NSLog(@"success with NSKeyedArchiver cashing allowed users");
    }
}

+ (NSMutableDictionary *) GetLog
{
    NSMutableDictionary *ProfileObject = [[NSMutableDictionary alloc] init];
    // get paths from root direcory
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    // get documents path
    NSString *documentsPath = [paths objectAtIndex:0];
    // get the path to our Data/plist file
    NSString *path= [documentsPath stringByAppendingPathComponent:@"BTracLogs.plist"];
    
    NSError *errorPath;
    
    // check to see if Data.plist exists in documents
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        // if not in documents, get property list from main bundle
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"BTracLogs" ofType:@"plist"];
        [[NSFileManager defaultManager] copyItemAtPath:bundle toPath: path error:&errorPath];
    }
    
    // read property list into memory as an NSData object
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    
    // convert static property list into dictionary object
    ProfileObject = (NSMutableDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    
    
    [ProfileObject writeToFile:path atomically:YES];
    
    return ProfileObject;
}

+ (NSData *) postLogsDataToServer
{
    // get paths from root direcory
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    // get documents path
    NSString *documentsPath = [paths objectAtIndex:0];
    // get the path to our Data/plist file
    
    NSString *offlinePlist=[NSString stringWithFormat:@"BTracLogs.plist"];
    NSString *path= [documentsPath stringByAppendingPathComponent:offlinePlist];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSMutableDictionary *profileObj = [[NSMutableDictionary alloc]init];
        profileObj = [self GetProfile];
        if( [profileObj objectForKey:@"paxInfo"] != nil ){
            NSString *flight = [profileObj objectForKey:@"flightInfo"];
            NSString *pax = [profileObj objectForKey:@"paxInfo"];
        
            NSMutableDictionary *logsDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            NSLog(@"logsData: %@",logsDictionary);
            if ([logsDictionary isKindOfClass:[NSMutableDictionary class]]) {
                if ([[logsDictionary objectForKey:@"log"] count]>3) {
                    NSMutableDictionary *logsData=[[NSMutableDictionary alloc] init];
                    [logsData setObject:pax forKey:@"Passenger"];
                    [logsData setObject:flight forKey:@"Flight"];
                    [logsData setObject:[logsDictionary objectForKey:@"startTime"] forKey:@"startTime"];
                    
                    // the log element is an array we convert it to NSDATA (binary object)
                    NSData *logDataObj=[NSKeyedArchiver archivedDataWithRootObject:[logsDictionary objectForKey:@"log"]];
                    
                    // then we encode it to string base64 (serialise object)
                    NSString *logStrObj=[StringObject encodeBase64WithData:logDataObj];
                    
                    // we add it to the payload with the other elements in a dictionary format
                    [logsData setObject:logStrObj forKey:@"log"];
                    
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
                    
                    [logsData setObject:[formatter stringFromDate:[NSDate date]] forKey:@"endTime"];
                    [logsData setObject:[formatter stringFromDate:[NSDate date]] forKey:@"lastUpdate"];
                    
                    NSLog(@"logsData: %@",logsData);
                    
                    NSError *error;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:logsData options:NSJSONWritingPrettyPrinted error:&error];
                    
                    if (jsonData) {
                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                    }
                }
            }
        }
    }
    return nil;
}

@end
