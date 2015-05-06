//
//  HTTPRequestCreator.m
//  CrewPad
//
//  Created by Kevin OSullivan on 02/05/2012.
//  Copyright (c) 2012 ITXi. All rights reserved.
//

#import "AppDelegate.h"
#import "HTTPRequestCreator.h"
#import "Constants.h"

static NSMutableDictionary *mapURLsTiming;

@implementation HTTPRequestCreator

+ (void) initialize {
    mapURLsTiming = [[NSMutableDictionary alloc] init];
}

/**
 * prepareAndCallHTTP_GET_RequestWithURL is a convenience static method that sets the HTTP REST API call standard headers/authentication/compression etc.
 */
+ (ASIHTTPRequest *) prepareAndCallHTTP_GET_RequestWithURL:(NSURL *)url AndRequestType:(NSString*)requestType AndDelegate:(id) delegate AndSuccessSelector:(SEL)finishSelector AndFailSelector:(SEL)failSelector
{
    NSLog(@"Calling API %@",  url);
    ASIHTTPRequest *httpGETRequest = [ASIHTTPRequest requestWithURL:url];
    [httpGETRequest setValidatesSecureCertificate:NO];
    [httpGETRequest addRequestHeader:@"Content-Type" value:@"application/json"];
    [httpGETRequest setTimeOutSeconds:15];
    [httpGETRequest addRequestHeader:@"X-ApplicationId" value:
     [NSString stringWithFormat:@"aero.developer.beacons.BeaconTrac.zz.%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]]];
    
    [httpGETRequest addRequestHeader:@"X-ApplicationVersion" value:
    [NSString stringWithFormat:@"%@-%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    
    [httpGETRequest addRequestHeader:@"X-DeviceTypeVersion" value: [NSString stringWithFormat:@"%@-%@", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion]]];
    
    [httpGETRequest addRequestHeader:@"Accept" value:@"application/json"];
    [httpGETRequest setRequestMethod:requestType];
    [httpGETRequest setAllowCompressedResponse:YES];
    [httpGETRequest setNumberOfTimesToRetryOnTimeout:1];
    
    [httpGETRequest setDelegate:delegate];
    [httpGETRequest setDidFinishSelector:finishSelector];
    [httpGETRequest setDidFailSelector:failSelector];

    [HTTPRequestCreator logStartRESTAPICall: httpGETRequest]; 
    [httpGETRequest startAsynchronous];
    return httpGETRequest;
}

/**
 * prepareLoginAndCallHTTP_GET_RequestWithURL is a convenience static method that sets the HTTP REST API call standard headers/authentication/compression etc.
 */
+ (ASIHTTPRequest *) prepareLoginAndCallHTTP_GET_RequestWithURL:(NSURL *)url AndRequestType:(NSString*)requestType AndDelegate:(id) delegate AndSuccessSelector:(SEL)finishSelector AndFailSelector:(SEL)failSelector
{
    
    NSLog(@"Calling API 1 %@",  url);
    ASIHTTPRequest *httpGETRequest = [ASIHTTPRequest requestWithURL:url];
    [httpGETRequest setValidatesSecureCertificate:NO];
    [httpGETRequest addRequestHeader:@"Content-Type" value:@"application/json"];
    [httpGETRequest addRequestHeader:@"X-apiKey" value:[AppDelegate sharedAppDelegate].BeaconKey];
    [httpGETRequest addRequestHeader:@"Accept" value:@"application/json"];
    [httpGETRequest addRequestHeader:@"X-ApplicationId" value:
     [NSString stringWithFormat:@"aero.developer.beacons.BeaconTrac.zz.%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]]];
    
    [httpGETRequest addRequestHeader:@"X-ApplicationVersion" value:
     [NSString stringWithFormat:@"%@-%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [httpGETRequest addRequestHeader:@"X-DeviceTypeVersion" value: [NSString stringWithFormat:@"%@-%@", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion]]];
    
    [httpGETRequest setRequestMethod:requestType];
    [httpGETRequest setAllowCompressedResponse:YES];
    [httpGETRequest setTimeOutSeconds:15];
    [httpGETRequest setNumberOfTimesToRetryOnTimeout:1];
    [httpGETRequest setDelegate:delegate];
    [httpGETRequest setDidFinishSelector:finishSelector];
    [httpGETRequest setDidFailSelector:failSelector];
    [HTTPRequestCreator logStartRESTAPICall: httpGETRequest];
    [httpGETRequest startAsynchronous];
    return httpGETRequest;
}

/**
 * prepareAndCallHTTP_POST_RequestWithURL is a convenience static method that sets the HTTP REST API call standard headers/authentication/compression etc.
 */
+ (ASIHTTPRequest *) prepareAndCallHTTP_POST_RequestWithURL:(NSURL *)url AndPostData:(NSData*)postData AndDelegate:(id)delegate AndSuccessSelector:(SEL)finishSelector AndFailSelector:(SEL)failSelector 
{
    NSLog(@"Calling API %@",  url);
    ASIHTTPRequest *httpRequest = [ASIHTTPRequest requestWithURL:url];
    [httpRequest setValidatesSecureCertificate:NO];
    [httpRequest addRequestHeader:@"Content-Type" value:@"application/json"];
    [httpRequest setTimeOutSeconds:15];
    [httpRequest addRequestHeader:@"X-ApplicationId" value:
     [NSString stringWithFormat:@"aero.developer.beacons.BeaconTrac.zz.%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]]];
    
    [httpRequest addRequestHeader:@"X-ApplicationVersion" value:
     [NSString stringWithFormat:@"%@-%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [httpRequest addRequestHeader:@"X-DeviceTypeVersion" value: [NSString stringWithFormat:@"%@-%@", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion]]];
    
    [httpRequest addRequestHeader:@"Accept" value:@"application/json"];
    
    [httpRequest setRequestMethod:@"POST"];
    [httpRequest appendPostData:postData];
    [httpRequest setAllowCompressedResponse:YES];
    [httpRequest setNumberOfTimesToRetryOnTimeout:1];
    [httpRequest setDelegate:delegate];
    [httpRequest setDidFinishSelector:finishSelector];
    [httpRequest setDidFailSelector:failSelector];
    [HTTPRequestCreator logStartRESTAPICall: httpRequest];
    [httpRequest startAsynchronous]; 
    return httpRequest;
}

+ (ASIHTTPRequest *) prepareAndCallHTTP_PUT_RequestWithURL:(NSURL *)url AndPostData:(NSData*)postData AndDelegate:(id)delegate AndSuccessSelector:(SEL)finishSelector AndFailSelector:(SEL)failSelector
{
    NSLog(@"Calling API %@",  url);
    ASIHTTPRequest *httpRequest = [ASIHTTPRequest requestWithURL:url];
    [httpRequest setValidatesSecureCertificate:NO];
    [httpRequest setTimeOutSeconds:15];
    [httpRequest addRequestHeader:@"X-ApplicationId" value:
     [NSString stringWithFormat:@"aero.developer.beacons.BeaconTrac.zz.%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]]];
    
    [httpRequest addRequestHeader:@"X-ApplicationVersion" value:
     [NSString stringWithFormat:@"%@-%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [httpRequest addRequestHeader:@"X-DeviceTypeVersion" value: [NSString stringWithFormat:@"%@-%@", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion]]];
    
    [httpRequest addRequestHeader:@"Accept" value:@"application/json"];
    
    [httpRequest setRequestMethod:@"put"];
    [httpRequest appendPostData:postData];
    [httpRequest setAllowCompressedResponse:YES];
    [httpRequest setNumberOfTimesToRetryOnTimeout:1];
    [httpRequest setDelegate:delegate];
    [httpRequest setDidFinishSelector:finishSelector];
    [httpRequest setDidFailSelector:failSelector];
    [HTTPRequestCreator logStartRESTAPICall: httpRequest];
    [httpRequest startAsynchronous];
    return httpRequest;
}

+ (ASIHTTPRequest *) prepareAndCallHTTP_PUT_RequestWithURLChangePass:(NSURL *)url AndPostData:(NSData*)postData AndDelegate:(id)delegate AndSuccessSelector:(SEL)finishSelector AndFailSelector:(SEL)failSelector
{
    NSLog(@"Calling API %@",  url);
    ASIHTTPRequest *httpRequest = [ASIHTTPRequest requestWithURL:url];
    [httpRequest setValidatesSecureCertificate:NO];
    [httpRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [httpRequest addRequestHeader:@"X-apiKey" value:[AppDelegate sharedAppDelegate].BeaconKey];
    [httpRequest setTimeOutSeconds:15];
    [httpRequest addRequestHeader:@"X-ApplicationId" value:
     [NSString stringWithFormat:@"aero.developer.bag.mh.%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]]];
    
    [httpRequest addRequestHeader:@"X-ApplicationVersion" value:
     [NSString stringWithFormat:@"%@-%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [httpRequest addRequestHeader:@"X-DeviceTypeVersion" value: [NSString stringWithFormat:@"%@-%@", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion]]];
    [httpRequest addRequestHeader:@"Accept" value:@"application/json"];
    [httpRequest setRequestMethod:@"put"];
    [httpRequest appendPostData:postData];
    [httpRequest setAllowCompressedResponse:YES];
    [httpRequest setNumberOfTimesToRetryOnTimeout:1];
    [httpRequest setDelegate:delegate];
    [httpRequest setDidFinishSelector:finishSelector];
    [httpRequest setDidFailSelector:failSelector];
    [HTTPRequestCreator logStartRESTAPICall: httpRequest];
    [httpRequest startAsynchronous];
    return httpRequest;
}

/**
 * Log the start of the API call.
 */
+ (void) logStartRESTAPICall: (ASIHTTPRequest *)request
{
    NSNumber *now = [NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()];
    /*
    NSString *logMessage = [NSString stringWithFormat:@"[API START: %@]", [HTTPRequestCreator stripPasswordFromURL:[request url]]];
    
    [Flurry logEvent:logMessage timed:YES];
    */
    [mapURLsTiming setObject :now forKey:[request url]];
}

/**
 * Log the end of the API call - all setDidFailSelector methods should call this.
 */
+ (void) logEndRESTAPICall: (ASIHTTPRequest *)request
{
    
}
@end
