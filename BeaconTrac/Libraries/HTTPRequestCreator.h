//
//  HTTPRequestCreator.h
//  CrewPad
//
//  Created by Kevin OSullivan on 02/05/2012.
//  Copyright (c) 2012 ITXi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface HTTPRequestCreator : NSObject


+ (ASIHTTPRequest *) prepareAndCallHTTP_GET_RequestWithURL:(NSURL *)url AndRequestType:(NSString*)requestType AndDelegate:(id) delegate AndSuccessSelector:(SEL)finishSelector AndFailSelector:(SEL)failSelector;

+ (void) logStartRESTAPICall: (ASIHTTPRequest *)request;
+ (void) logEndRESTAPICall: (ASIHTTPRequest *)request;
@end