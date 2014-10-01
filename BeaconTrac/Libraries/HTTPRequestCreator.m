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
    [httpGETRequest addRequestHeader:@"X-ApplicationId" value: appId];
    
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
 * Log the start of the API call.
 */
+ (void) logStartRESTAPICall: (ASIHTTPRequest *)request
{
    NSNumber *now = [NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()];
    /*
    NSString *logMessage = [NSString stringWithFormat:@"[API START: %@]", [HTTPRequestCreator stripPasswordFromURL:[request url]]];
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
